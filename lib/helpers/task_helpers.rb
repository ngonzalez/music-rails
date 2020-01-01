module TaskHelpers
  def clear_deleted_folders
    (Release.pluck(:folder).uniq - FOLDERS - FOLDERS_WITH_SUBFOLDERS).each do |folder|
      Release.where(folder: folder).destroy_all
    end
  end

  def import_folders
    items = Release.pluck :name
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
    items = Release.pluck :name
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
    if !File.directory? release.decorate.public_path
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
      release.destroy if !File.directory? release.decorate.public_path
    end
  end

  def update_release_folder_dates release
    f = File::Stat.new release.decorate.public_path
    if f.birthtime != release.folder_created_at || f.mtime != release.folder_updated_at
      release.update! folder_created_at: f.birthtime, folder_updated_at: f.mtime
    end
  end

  def set_changes release, folder, source, subfolder=nil
    if File.directory? [BASE_PATH, folder, subfolder, source, release.name].reject(&:blank?).join('/')
      release.update!(source: source) if release.read_attribute(:source) != source
      release.update!(folder: folder) if release.folder != folder
      release.update!(subfolder: subfolder) if release.subfolder != subfolder
    end
  end

  def update_releases_data_url
    Release.where(data_url: nil).each do |release|
      next unless release.formatted_name
      data_url = release.formatted_name.downcase.gsub(' ', '-').gsub('_', '-').gsub('__', '-').gsub('--', '-')
      begin
        release.update!(data_url: data_url)
      rescue ActiveRecord::RecordNotUnique
        data_url = [data_url, rand(1000) * rand(1000)].join('-')
        release.update!(data_url: data_url)
      end
    end
  end

  def update_releases_year
    Release.where(year: nil).each do |release|
      next unless release.tracks.any?
      year = release.tracks[0].year.to_i
      release.update! year: year
    end
  end

  def update_releases_formatted_name
    Release.where(formatted_name: nil).each do |release|
      next unless release.year
      array = release.name.gsub("_-_", "-").gsub(".", "").split("-")
      array -= ALLOWED_SOURCES
      array -= FORMAT_NAME_STRINGS
      array -= SUPPORTED_AUDIO_FORMATS.map &:last
      next unless array.index(release.year)
      formatted_name = array[0..array.index(release.year)-1].join(" ").gsub("_", " ")
      release.update! formatted_name: formatted_name
    end
  end

  def unchecked_releases
    Release.includes([:sfv_files, :tracks])
      .where(last_verified_at: nil)
      .select { |release| !release.details.has_key?(:sfv) }
  end

  def run_check_sfv release, sfv_file
    case Dir.chdir([release.decorate.public_path, sfv_file.base_path].join('/')) { %x[cfv -f #{sfv_file.file.path}] }
      when /#{sfv_file.file_names.length} files, #{sfv_file.file_names.length} OK/ then :ok
      when /badcrc/ then :bad_crc
      when /chksum file errors/ then :chksum_file_errors
      when /not found|No such file/ then :missing_files
    end
  end

  def check_sfv release
    return if release.last_verified_at || release.details[:sfv]
    results = release.sfv_files.decorate.collect { |sfv_file| run_check_sfv(release, sfv_file) }
    if results.all? { |result| result == :ok }
      release.details.delete(:sfv) if release.details.has_key?(:sfv)
      release.update!(last_verified_at: Time.now) if !release.last_verified_at
    else
      release.details[:sfv] = results
      release.save!
    end
  end
end
