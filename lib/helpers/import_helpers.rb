require 'taglib'

module ImportHelpers

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
      ["bitrate", "channels", "length", "sample_rate"].each do |name|
        audio_file.send "#{name}=", audio_properties.send(name)
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
