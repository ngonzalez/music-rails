module ImportHelpers
  require 'taglib'
  def create_track release, track_path, file_name
    track = folder.tracks.new name: file_name
    track.format_info = `file -b #{Shellwords.escape(track_path)}`.force_encoding('Windows-1252').encode('UTF-8').gsub("\n", "").strip
    TagLib::FileRef.open(track_path) do |infos|
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
  def create_image release, image_path, file_name
    folder.images.create! file: File.open(image_path), file_name: file_name
  rescue Dragonfly::Shell::CommandFailed => e
    Rails.logger.info "Failed to generate Image: %s" % folder.name
  end
  def clear_text string
    string.force_encoding('Windows-1252').encode('UTF-8').gsub("\C-M", "")
  end
  def base_path release, path
    array = path.split "/"
    array = array[array.index(folder.name)..array.length] - [folder.name]
    array.length > 1 ? array[0] : nil
  end
  def import_file release, collection, path, file_name
    f = Tempfile.new
    f.write(clear_text(File.read(path))) ; f.rewind
    folder.send(collection).create! file: f, file_name: file_name, base_path: base_path(release, path)
  ensure
    f.try :unlink
  end
  def list_files release_path, format, &_
    Dir[release_path + "/**/*.#{format}",
        release_path + "/**/*.#{format.upcase}" ].each do |path|
      yield path, path.split("/").last
    end
  end
end