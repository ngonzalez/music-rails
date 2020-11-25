module TaskHelpers
  def clear_deleted_folders
    (Folder.pluck(:folder).uniq - FOLDERS - FOLDERS_WITH_SUBFOLDERS).each do |folder|
      Folder.where(folder: folder).destroy_all
    end
  end

  def import_folders
    items = Folder.pluck :name
    FOLDERS.each do |folder|
      ALLOWED_SOURCES.each do |source|
        Dir["#{BASE_PATH}/#{folder}/#{source}/**"].each do |path|
          name = path.split("/").last
          next if EXCEPT_RLS.include?(name) || items.include?(name)
          ImportWorker.new(path: path, name: name,
            folder: folder, source: source).perform
        end
      end
    end
  end

  def import_subfolders
    items = Folder.pluck :name
    FOLDERS_WITH_SUBFOLDERS.each do |folder_path|
      Dir["#{BASE_PATH}/#{folder_path}/**"].each do |subfolder_path|
        ALLOWED_SOURCES.each do |source|
          Dir["#{subfolder_path}/#{source}/**"].each do |path|
            name = path.split("/").last
            subfolder = subfolder_path.split("/").last
            folder = subfolder_path.gsub("#{BASE_PATH}/", "").gsub("/#{subfolder}", "")
            next if EXCEPT_RLS.include?(name) || items.include?(name)
            ImportWorker.new(path: path, name: name,
              folder: folder, source: source, subfolder: subfolder).perform
          end
        end
      end
    end
  end

  def update_release_path release
    if !File.directory? folder.decorate.public_path
      FOLDERS.each do |folder|
        ALLOWED_SOURCES.each do |source|
          set_changes release, folder, source
        end
      end
      FOLDERS_WITH_SUBFOLDERS.each do |folder|
        Dir["#{BASE_PATH}/#{folder}/**"].map { |name| name.split("/").last }.each do |subfolder|
          ALLOWED_SOURCES.each do |source|
            set_changes release, folder, source, subfolder
          end
        end
      end
      folder.destroy if !File.directory? folder.decorate.public_path
    end
  end

  def update_release_folder_dates release
    return unless File.exists?(folder.decorate.public_path)
    f = File::Stat.new folder.decorate.public_path
    if f.birthtime != folder.folder_created_at || f.mtime != folder.folder_updated_at
      folder.update! folder_created_at: f.birthtime, folder_updated_at: f.mtime
    end
  end

  def set_changes release, folder, source, subfolder=nil
    if File.directory? [BASE_PATH, folder, subfolder, source, folder.name].reject(&:blank?).join('/')
      folder.update!(source: source) if folder.read_attribute(:source) != source
      folder.update!(folder: folder) if folder.folder != folder
      folder.update!(subfolder: subfolder) if folder.subfolder != subfolder
    end
  end

  def update_releases_data_url
    Folder.where(data_url: nil).each do |folder|
      next unless folder.formatted_name
      data_url = folder.formatted_name.downcase.gsub(' ', '-').gsub('_', '-').gsub('__', '-').gsub('--', '-')
      begin
        folder.update!(data_url: data_url)
      rescue ActiveRecord::RecordNotUnique
        data_url = [data_url, rand(1000) * rand(1000)].join('-')
        folder.update!(data_url: data_url)
      end
    end
  end

  def update_tracks_data_url
    AudioFile.where(data_url: nil).each do |track|
      track = track.decorate
      begin
        data_url = track.format_name
      rescue
        next
      end
      data_url = track.name.gsub '.%s' % track.format_name.downcase, ''
      begin
        track.update! data_url: data_url
      rescue ActiveRecord::RecordNotUnique
        data_url = [data_url, rand(1000) * rand(1000)].join('-')
        track.update! data_url: data_url
      end
    end
  end

  def update_releases_year
    Folder.where(year: nil).each do |folder|
      next unless folder.tracks.any?
      year = folder.tracks[0].year.to_i
      folder.update! year: year
    end
  end

  def update_releases_formatted_name
    Folder.where(formatted_name: nil).each do |folder|
      next unless folder.year
      array = folder.name.gsub('_-_', '-').gsub('.', '').gsub('-', ' ').split(' ')
      array -= ALLOWED_AUDIO_FORMATS.keys
      array -= ALLOWED_SOURCES
      EXCEPT_NAMES.each do |string|
        array.reject! { |str| str == string }
      end
      array.each_with_index do |item, i|
        array_item = item.split '_'
        EXCEPT_NAMES.each do |string|
          array_item.reject! { |str| str == string }
        end
        array[i] = array_item.join ' '
      end
      next unless array.index(folder.year)
      formatted_name = array[0..array.index(folder.year)-1].join(' ').gsub('_', ' ')
      folder.update! formatted_name: formatted_name
    end
  end

  def unchecked_releases
    Folder.includes([:sfv_files])
      .where(last_verified_at: nil)
      .select { |folder| !folder.details.has_key?(:sfv) }
  end

  def run_check_sfv release, sfv_file
    case Dir.chdir([folder.decorate.public_path, sfv_file.base_path].join('/')) { %x[cfv -f #{sfv_file.file.path}] }
      when /#{sfv_file.file_names.length} files, #{sfv_file.file_names.length} OK/ then :ok
      when /badcrc/ then :bad_crc
      when /chksum file errors/ then :chksum_file_errors
      when /not found|No such file/ then :missing_files
    end
  end

  def check_sfv release
    results = if folder.sfv_files.any?
      folder.sfv_files.decorate.collect { |sfv_file| run_check_sfv(release, sfv_file) }
    else
      [:sfv_file_not_found]
    end
    if results.all? { |result| result == :ok }
      folder.update! last_verified_at: Time.now
    else
      folder.details[:sfv] = results
      folder.save!
    end
  end
end
