class ImportWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  attr_accessor :release

  def initialize options={}
    @release = options[:release] if options[:release]
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
          track.format = `file -b #{Shellwords.escape(file)}`.force_encoding('Windows-1252').encode('UTF-8').gsub("\n", "").strip
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
    temp_file = "/tmp/#{Time.now.to_i}"
    font = Rails.root + "app/assets/fonts/ProFont/ProFontWindows.ttf"
    [NFO_TYPE].each do |format|
      Dir["#{release.decorate.public_path}/*.#{format}"].each do |nfo_path|
        file_name = nfo_path.split("/").last
        next if release.nfo_files.detect{|nfo_file| nfo_file.file_name == file_name }
        begin
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
          content = Dragonfly.app.generate(:text, "@#{temp_file}", { 'font': font.to_s, 'format': 'svg' })
          release.nfo_files.create! file: content, file_name: file_name
        rescue
          Rails.logger.info "NFO: Failed to import: #{file_name}"
          next
        end
      end
    end
    FileUtils.rm(temp_file) if File.exists?(temp_file)
  end
  def set_release options
    return if release
    @release = Release.new name: options[:path].split("/").last, folder: options[:folder], source: options[:source]
    release.label_name = options[:label_name].gsub("_", " ") if options[:label_name]
    release.save!
  end
  def process_release options
    @release = Release.find_by name: options[:path].split("/").last
    return if release && release.last_verified_at
    return if release && release.details[:sfv]
    ActiveRecord::Base.transaction do
      begin
        set_release options
        import_tracks
        import_images
        import_nfo
      rescue Exception => e
        Rails.logger.info options.inspect
        raise ActiveRecord::Rollback
      end
    end
  end

end