module TaskHelpers

  def import_music_folders
    clear_deleted_folders
    MusicFolder.find_each do |music_folder|
      update_folder_path music_folder
      update_folder_dates music_folder
    end
    import_folders
    import_subfolders
    update_music_folders_year
    update_music_folders_formatted_name
    update_music_folders_data_url
    update_audio_files_data_url
  end

  def clear_database
    ActiveRecord::Base.connection.execute "DELETE FROM #{MusicFolder.table_name} WHERE deleted_at IS NOT NULL"
    ActiveRecord::Base.connection.execute "DELETE FROM #{Image.table_name} WHERE deleted_at IS NOT NULL"
    ActiveRecord::Base.connection.execute "DELETE FROM #{AudioFile.table_name} WHERE deleted_at IS NOT NULL"
    ActiveRecord::Base.connection.execute "DELETE FROM #{M3uFile.table_name} WHERE deleted_at IS NOT NULL"
  end

  def clear_deleted_folders
    (MusicFolder.pluck(:folder).uniq - FOLDERS - FOLDERS_WITH_SUBFOLDERS).each do |folder|
      MusicFolder.where(folder: folder).destroy_all
    end
  end

  def import_folders
    items = MusicFolder.pluck :name
    FOLDERS.each do |folder|
      ALLOWED_SOURCES.each do |source|
        Dir["#{BASE_PATH}/#{folder}/#{source}/**"].each do |path|
          name = path.split("/").last
          ImportWorker.new(path: path, name: name,
            folder: folder, source: source).perform
        end
      end
    end
  end

  def import_subfolders
    items = MusicFolder.pluck :name
    FOLDERS_WITH_SUBFOLDERS.each do |folder_path|
      Dir["#{BASE_PATH}/#{folder_path}/**"].each do |subfolder_path|
        ALLOWED_SOURCES.each do |source|
          Dir["#{subfolder_path}/#{source}/**"].each do |path|
            name = path.split("/").last
            subfolder = subfolder_path.split("/").last
            folder = subfolder_path.gsub("#{BASE_PATH}/", "").gsub("/#{subfolder}", "")
            ImportWorker.new(path: path, name: name,
              folder: folder, source: source, subfolder: subfolder).perform
          end
        end
      end
    end
  end

  def update_folder_path music_folder
    if !File.directory? music_folder.decorate.public_path
      FOLDERS.each do |folder|
        ALLOWED_SOURCES.each do |source|
          set_changes music_folder, folder, source
        end
      end
      FOLDERS_WITH_SUBFOLDERS.each do |folder|
        Dir["#{BASE_PATH}/#{folder}/**"].map { |name| name.split("/").last }.each do |subfolder|
          ALLOWED_SOURCES.each do |source|
            set_changes music_folder, folder, source, subfolder
          end
        end
      end
      music_folder.destroy if !File.directory? music_folder.decorate.public_path
    end
  end

  def update_folder_dates music_folder
    return unless File.exists?(music_folder.decorate.public_path)
    f = File::Stat.new music_folder.decorate.public_path
    if f.birthtime != music_folder.folder_created_at || f.mtime != music_folder.folder_updated_at
      music_folder.update! folder_created_at: f.birthtime, folder_updated_at: f.mtime
    end
  end

  def set_changes music_folder, folder, source, subfolder=nil
    if File.directory? [BASE_PATH, folder, subfolder, source, folder.name].reject(&:blank?).join('/')
      music_folder.update!(source: source) if music_folder.read_attribute(:source) != source
      music_folder.update!(folder: folder) if music_folder.folder != folder
      music_folder.update!(subfolder: subfolder) if music_folder.subfolder != subfolder
    end
  end

  def update_music_folders_data_url
    MusicFolder.where(data_url: nil).each do |music_folder|
      next unless music_folder.formatted_name
      data_url = music_folder.formatted_name.downcase.gsub(' ', '-').gsub('_', '-').gsub('__', '-').gsub('--', '-')
      data_url = data_url.gsub(/[^\_\-0-9a-z ]/i, '')
      begin
        music_folder.update!(data_url: data_url)
      rescue ActiveRecord::RecordNotUnique
        data_url = [data_url, rand(1000) * rand(1000)].join('-')
        music_folder.update!(data_url: data_url)
      end
    end
  end

  def update_audio_files_data_url
    AudioFile.where(data_url: nil).each do |audio_file|
      audio_file = audio_file.decorate
      data_url = audio_file.format_name rescue next
      data_url = audio_file.name.downcase.gsub '.%s' % audio_file.format_name.downcase, ''
      data_url = data_url.gsub(/[^\_\-0-9a-z ]/i, '')
      begin
        audio_file.update! data_url: data_url
      rescue ActiveRecord::RecordNotUnique
        data_url = [data_url, rand(1000) * rand(1000)].join('-')
        audio_file.update! data_url: data_url
      end
    end
  end

  def update_music_folders_year
    MusicFolder.where(year: nil).each do |music_folder|
      next unless music_folder.audio_files.any?
      year = music_folder.audio_files[0].year.to_i
      music_folder.update! year: year
    end
  end

  def update_music_folders_formatted_name
    MusicFolder.where(formatted_name: nil).each do |music_folder|
      next unless music_folder.year
      array = music_folder.name.gsub('_-_', '-').gsub('.', '').gsub('-', ' ').split(' ')
      array -= ALLOWED_AUDIO_FORMATS.keys
      array -= ALLOWED_SOURCES
      next unless array.index(music_folder.year)
      formatted_name = array[0..array.index(music_folder.year)-1].join(' ').gsub('_', ' ')
      formatted_name = formatted_name.gsub(/[^\_\-0-9a-z ]/i, '')
      music_folder.update! formatted_name: formatted_name
    end
  end

end
