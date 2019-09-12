module ImportHelpers
  require 'taglib'
  def create_track release, track_path, file_name
    track = release.tracks.new name: file_name
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
    release.images.create! file: File.open(image_path), file_name: file_name
  rescue Dragonfly::Shell::CommandFailed => e
    Rails.logger.info "Failed to generate Image: %s" % release.name
  end
  def create_nfo release, nfo_path, file_name
    temp_file = "/tmp/#{Time.now.to_i * rand(10000)}"
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
      content = Dragonfly.app.generate :text, "@#{temp_file}", {
        'format': 'svg',
        'font': Rails.root + "app/assets/fonts/ProFont/ProFontWindows.ttf"
      }
      release.nfo_files.create! file: content, file_name: file_name
    rescue Dragonfly::Shell::CommandFailed => e
      Rails.logger.info "Failed to generate NFO: %s" % release.name
    ensure
      FileUtils.rm(temp_file) if File.exists?(temp_file)
    end
  end
  def clear_text string
    string.force_encoding('Windows-1252').encode('UTF-8').gsub("\C-M", "")
  end
  def import_file release, collection, path, file_name
    f = Tempfile.new
    f.write(clear_text(File.read(path))) ; f.rewind
    release.send(collection).create! file: f, file_name: file_name
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