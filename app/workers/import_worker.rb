require 'taglib'

class ImportWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  attr_accessor :music_folder

  def initialize options={}
    @music_folder = MusicFolder.create! options.slice(*[:name, :folder, :subfolder, :source])
    f = File::Stat.new music_folder.decorate.public_path
    music_folder.update! folder_created_at: f.birthtime, folder_updated_at: f.mtime
  end

  def perform
    ALLOWED_AUDIO_FORMATS.flat_map { |_, format| format[:extensions] }.each do |format|
      list_files(music_folder.decorate.public_path, format) do |path, file_name|
        next if music_folder.audio_files.detect { |audio_file| audio_file.name == file_name }
        begin
          create_audio_file music_folder, path, file_name
        rescue => e
          Rails.logger.error e
          next
        end
      end
    end

    ALLOWED_IMAGE_FORMATS.flat_map { |_, format| format[:extensions] }.each do |format|
      list_files(music_folder.decorate.public_path, format) do |path, file_name|
        next if music_folder.images.detect { |image| image.file_name == file_name }
        begin
          create_image music_folder, path, file_name
        rescue => e
          Rails.logger.error e
          next
        end
      end
    end

    ALLOWED_FILE_FORMATS.flat_map { |_, format| format[:extensions] }.each do |format|
      list_files(music_folder.decorate.public_path, format) do |path, file_name|
        next if music_folder.send("#{format}_files".to_sym).detect { |item| item.file_name == file_name }
        begin
          import_file music_folder, "#{format}_files".to_sym, path, file_name
        rescue => e
          Rails.logger.error e
          next
        end
      end
    end
  end

    private

  def create_audio_file music_folder, file_path, file_name
    audio_file = music_folder.audio_files.new name: file_name
    begin
      file_infos = `file -b #{Shellwords.escape(file_path)}`
      audio_file.format_info = file_infos.force_encoding('Windows-1252').encode('UTF-8').gsub("\n", "").strip
    rescue Encoding::UndefinedConversionError => e
      raise e
    end
    TagLib::FileRef.open(file_path) do |infos|
      tag = infos.tag
      ["artist", "title", "album", "genre", "year"].each do |name|
        audio_file.send "#{name}=", tag.send(name)
      end
      audio_properties = infos.audio_properties
      ["bitrate", "channels", "length_in_seconds", "sample_rate"].each do |name|
        audio_file.send "#{name}=", audio_properties.send(name) rescue binding.pry
      end
    end
    audio_file.save!
  end

  def create_image music_folder, file_path, file_name
    music_folder.images.create! file: File.open(file_path), file_name: file_name
  rescue Dragonfly::Shell::CommandFailed => e
    Rails.logger.info "Failed to generate Image: %s" % music_folder.name
  end

  def clear_text string
    string.force_encoding('Windows-1252').encode('UTF-8').gsub("\C-M", "")
  end

  def base_path music_folder, folder_path
    array = folder_path.split "/"
    array = array[array.index(music_folder.name)..array.length] - [music_folder.name]
    array.length > 1 ? array[0] : nil
  end

  def import_file music_folder, collection, file_path, file_name
    f = Tempfile.new
    f.write(clear_text(File.read(file_path))) ; f.rewind
    music_folder.send(collection).create! file: f, file_name: file_name, base_path: base_path(music_folder, file_path)
  ensure
    f.try :unlink
  end

  def list_files folder_path, format, &_
    Dir[folder_path + "/**/*.#{format}",
        folder_path + "/**/*.#{format.upcase}" ].each do |path|
      yield path, path.split("/").last
    end
  end

end
