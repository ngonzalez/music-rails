class ImportWorker

  class SrrdbLimitReachedError < StandardError ; end
  class SrrdbNotFound < StandardError ; end

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  attr_accessor :release

  def initialize options={}
    @release = options[:release] if options[:release]
    @release = Release.find_by options.slice(:name)
    set_release options if !release
  end

  def set_release options
    @release = Release.new options.slice(:name, :folder, :source)
    release.label_name = options[:label_name].gsub("_", " ") if options[:label_name]
    release.save!
  end

  def perform options
    ensure_db_connection
    process_release options.symbolize_keys
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
          ActiveRecord::Base.transaction do
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
              Rails.logger.info "Track: Failed to import: #{track.inspect}"
              raise ActiveRecord::Rollback
            end
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
        release.images.create! file: File.open(image_path)
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
          Rails.logger.info "NFO: Failed to import: #{file_name}"
        ensure
          FileUtils.rm(temp_file) if File.exists?(temp_file)
        end
      end
    end
  end
  def import_sfv
    Dir[release.decorate.public_path + "/**/*.#{SFV_TYPE}", release.decorate.public_path + "/**/*.#{SFV_TYPE.upcase}"].each do |sfv_path|
      file_name = sfv_path.split("/").each_with_object([]){|item, array| array << item if item == release.name || array.include?(release.name) }.reject{|item| item == release.name }.join "/"
      next if release.sfv_files.where(source: nil).detect{|sfv| sfv.file_name == file_name }
      release.sfv_files.create! file: File.read(sfv_path), file_name: file_name
    end
  end
  def srrdb_request url, &block
    request = Typhoeus::Request.new url, followlocation: true
    request.on_complete do |response|
      raise SrrdbNotFound.new("") if response.code != 200 || response.body.blank?
      raise SrrdbLimitReachedError.new response.body if response.body == "You've reached the daily limit."
      sleep 5
      yield response
    end
    request.run
  end
  def import_srrdb_sfv
    begin
      sfv_name = release_name = nil
      srrdb_request "http://www.srrdb.com/release/details/#{release.name}" do |response|
        release_name = Nokogiri::HTML(response.body).css('#release-name')[0]['value']
        sfv_files = Nokogiri::HTML(response.body).css('table.stored-files').css('a.storedFile').select{|item| item['href'].downcase =~ /.sfv/ }
        raise SrrdbNotFound.new if sfv_files.blank?
        sfv_files.each do |sfv_file|
          file_name = sfv_file['href'].split("/").each_with_object([]){|item, array| array << item if item == release_name || array.include?(release_name) }.reject{|item| item == release_name }.join "/"
          file_name = URI.unescape file_name
          next if release.sfv_files.where(source: 'srrDB').detect{|sfv| sfv.file_name == file_name }
          srrdb_request "http://www.srrdb.com/download/file/#{release_name}/#{file_name}" do |response|
            f = Tempfile.new ; f.write(response.body.force_encoding('Windows-1252').encode('UTF-8').gsub("\C-M", "")) ; f.rewind
            release.sfv_files.create! file: f, source: 'srrDB', file_name: file_name
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
  def check_sfv field_name, key
    return if release.send(field_name) || release.details[key]
    sfv = release.sfv_files.where(source: nil).take if key == :sfv
    sfv = release.sfv_files.where(source: 'srrDB').take if key == :srrdb_sfv
    return if !sfv
    sfv_check_results = Dir.chdir(release.decorate.public_path) { %x[#{SFV_CHECK_APP} -f #{sfv.file.path}] }
    if sfv_check_results =~ /#{release.tracks.length} files, #{release.tracks.length} OK/
      release.update! field_name => Time.now
    else
      details = case sfv_check_results
        when /badcrc/ then :bad_crc
        when /chksum file errors/ then :chksum_file_errors
        when /not found|No such file/ then :missing_files
      end
      if details
        release.details[key] = details
        release.save!
      end
    end
  end
  def process_release options
    return if release && (release.last_verified_at || release.details[:sfv])
    ActiveRecord::Base.transaction do
      begin
        import_tracks
        import_images
        import_nfo
        import_sfv
        check_sfv :last_verified_at, :sfv
        if release.decorate.scene?
          import_srrdb_sfv
          check_sfv :srrdb_last_verified_at, :srrdb_sfv
        end
      rescue Exception => e
        puts options.inspect
        Rails.logger.info options.inspect
        raise ActiveRecord::Rollback
      end
    end
  end

end