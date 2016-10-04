class ImportWorker

  class SrrdbLimitReachedError < StandardError ; end
  class SrrdbNotFound < StandardError ; end

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  attr_accessor :release

  def initialize options={}
    set_release options
  end

  def perform
    ensure_db_connection
    return if release && (release.last_verified_at || release.details[:sfv])
    import_tracks
    import_images
    import_nfo
    import_sfv
  end

  def set_release options
    @release = options[:release] if options[:release]
    @release = Release.where("LOWER(name) = ?", options[:name].downcase).take
    release_attributes = [:name, :folder, :subfolder, :source]
    if !@release
      @release = Release.new options.slice(*release_attributes)
      release.save!
    elsif @release && release_attributes.any?{|attr| @release.send("#{attr}_changed?") }
      release.update! options.slice(*release_attributes)
    end
  end

  def ensure_db_connection
    track = nil
    loop do
      begin
        track = Track.take
      rescue
        Rails.logger.info "\sLameWorker: DB Busy, Retrying.."
        sleep 1
      end
      break if !track.nil?
    end
  end

  require 'taglib'
  def import_tracks
    ALLOWED_AUDIO_FORMATS.each do |format|
      Dir["#{release.decorate.public_path}/*.#{format}"].each do |file|
        track_name = file.split("/").last
        track = release.tracks.detect{|track| track.name == track_name }
        if !track
          track = release.tracks.new name: track_name
          begin
            track.format_info = `file -b #{Shellwords.escape(file)}`.force_encoding('Windows-1252').encode('UTF-8').gsub("\n", "").strip
            TagLib::FileRef.open(file) do |infos|
              tag = infos.tag
              ["artist", "title", "album", "genre", "year"].each do |name|
                track.send "#{name}=", tag.send(name)
              end
              audio_properties = infos.audio_properties
              ["bitrate", "channels", "length", "sample_rate"].each do |name|
                track.send "#{name}=", audio_properties.send(name)
              end
            end
            track.save!
          rescue Exception => e
            Rails.logger.info "[track] Failed to import: #{track_name}"
          end
        end
      end
    end
  end
  def import_images
    ALLOWED_IMAGE_FORMATS.each do |format|
      Dir["#{release.decorate.public_path}/*.#{format}"].each do |image_path|
        file_name = image_path.split("/").last
        next if file_name =~ /.log./
        next if release.images.detect{|image| image.file_name == file_name }
        begin
          release.images.create! file: File.open(image_path)
        rescue
          Rails.logger.info "[image] Failed to import: #{file_name}"
        end
      end
    end
  end
  def import_nfo
    [NFO_TYPE].each do |format|
      Dir["#{release.decorate.public_path}/*.#{format}"].each do |nfo_path|
        file_name = nfo_path.split("/").last
        next if release.nfo_files.detect{|nfo_file| nfo_file.file_name == file_name }
        begin
          temp_file = "/tmp/#{Time.now.to_i * rand(10000)}"
          font = Rails.root + "app/assets/fonts/ProFont/ProFontWindows.ttf"
          File.open(temp_file, 'w:UTF-8') do |f|
            File.open(nfo_path).each_line do |line|
              # Remove ^M when copy files from Windows
              # https://en.wikipedia.org/wiki/Code_page_437
              f.write line.gsub("\C-M", "").force_encoding("CP437")
            end
          end
          # vi /usr/local/etc/ImageMagick-6/policy.xml
          # Remove following line:
          # <policy domain="path" rights="none" pattern="@*" />
          # http://www.imagemagick.org/discourse-server/viewtopic.php?t=29594
          # http://git.imagemagick.org/repos/VisualMagick/commit/d40df0bb10af73d946edd8e415d5e593420fc17e
          content = Dragonfly.app.generate :text, "@#{temp_file}", { 'font': font.to_s, 'format': 'svg' }
          release.nfo_files.create! file: content, file_name: file_name
        rescue
          Rails.logger.info "[nfo] Failed to import: #{file_name}"
        ensure
          FileUtils.rm(temp_file) if File.exists?(temp_file)
        end
      end
    end
  end
  def clear_text string
    string.force_encoding('Windows-1252').encode('UTF-8').gsub("\C-M", "")
  end
  def import_sfv
    Dir[release.decorate.public_path + "/**/*.#{SFV_TYPE}", release.decorate.public_path + "/**/*.#{SFV_TYPE.upcase}"].each do |sfv_path|
      file_name = sfv_path.split("/").each_with_object([]){|item, array| array << item if item == release.name || array.include?(release.name) }.reject{|item| item == release.name }.join "/"
      next if release.sfv_files.where(source: nil).detect{|sfv| sfv.file_name == file_name }
      f = Tempfile.new ; f.write(clear_text(File.read(sfv_path))) ; f.rewind
      release.sfv_files.create! file: f, file_name: file_name
      f.unlink
    end
  end
  def srrdb_request url, &block
    request = Typhoeus::Request.new url, followlocation: true
    request.on_complete do |response|
      raise SrrdbNotFound.new if response.code != 200 || response.body.blank?
      raise SrrdbLimitReachedError.new response.body if response.body == "You've reached the daily limit."
      sleep 5
      yield response
    end
    request.run
  end
  def import_srrdb_sfv
    begin
      srrdb_request "http://www.srrdb.com/release/details/#{release.name}" do |response|
        release_name = Nokogiri::HTML(response.body).css('#release-name')[0]['value']
        sfv_files = Nokogiri::HTML(response.body).css('table.stored-files').css('a.storedFile').select{|item| item['href'].downcase =~ /.sfv/ }
        raise SrrdbNotFound.new if sfv_files.blank?
        sfv_files.each do |sfv_file|
          file_name = sfv_file['href'].split("/").each_with_object([]){|item, array| array << item if item == release_name || array.include?(release_name) }.reject{|item| item == release_name }.join "/"
          file_name = URI.unescape file_name
          next if release.sfv_files.where(source: 'srrDB').detect{|sfv| sfv.file_name == file_name }
          srrdb_request "http://www.srrdb.com/download/file/#{release_name}/#{file_name}" do |response|
            f = Tempfile.new ; f.write(clear_text(response.body)) ; f.rewind
            release.sfv_files.create! file: f, file_name: file_name, source: 'srrDB'
            f.unlink
          end
        end
      end
    rescue SrrdbLimitReachedError => e
      Rails.logger.info "SRRDB: %s" % [ e.message ]
      return
    rescue SrrdbNotFound => e
      release.details[:srrdb_sfv_error] = true
      release.save!
      return
    end
  end
  def check_sfv source=nil
    key = source ? "#{source.downcase}_sfv".to_sym : :sfv
    field_name = source ? "#{source.downcase}_last_verified_at".to_sym : :last_verified_at
    return if release.send(field_name) || release.details[key]
    results = release.sfv_files.where(source: source).each_with_object([]){|sfv_file, array| array << sfv_file.check }
    if results.all?{|result| result == :ok }
      release.details.delete(key) if release.details.has_key?(key)
      release.update!(field_name => Time.now) if !release.send(field_name)
    else
      release.details[key] = results.uniq
      release.save!
    end
  end

end