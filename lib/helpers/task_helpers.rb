module TaskHelpers
  require Rails.root.join 'lib/helpers/release_helpers'
  include ReleaseHelpers

  def clear_deleted_folders
    (Release.pluck(:folder).uniq - FOLDERS - FOLDERS_WITH_SUBFOLDERS).each do |folder|
      Release.where(folder: folder).destroy_all
    end
  end

  def update_releases
    Release.find_each do |release|
      update_release_path release
      update_release_folder_dates release
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

  def release_set_details
    update_releases_format_name
    update_releases_formatted_name
    update_releases_data_url
    update_releases_year
    update_tracks_format_name
    update_tracks_number
  end

  def release_check_sfv
    unchecked_releases.each do |release|
      check_sfv release
    end
  end

  private

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
      data_url = release.formatted_name.downcase.gsub(' ', '-').gsub('_', '-').gsub('__', '-').gsub('--', '-')
      begin
        release.update! data_url: data_url
      rescue ActiveRecord::RecordNotUnique
        release.update! data_url: [data_url, rand(1000) * rand(1000)].join('-')
      end
    end
  end

  def update_releases_format_name
    Release.joins(:tracks).where(format_name: nil).each do |release|
      release.update! format_name: format_track_format(release.tracks[0])
    end
  end

  def update_releases_formatted_name
    Release.where(formatted_name: nil).each do |release|
      release.update! formatted_name: format_name(release.name)
    end
  end

  def update_releases_year
    Release.where(year: nil).each do |release|
      next if release.tracks.empty?
      release.update! year: release.tracks[0].year.to_i
    end
    Release.where("year::numeric = 0 OR year IS NULL").find_each do |release|
      year = year_from_name release.name
      next if !year
      release.tracks.each{|track| track.update! year: year }
      release.update! year: year
    end
  end

  def update_tracks_format_name
    Release.includes(:tracks).where(tracks: { format_name: nil }).each do |release|
      release.tracks.each do |track|
        track.update! format_name: format_track_format(track)
      end
    end
  end

  def update_tracks_number
    Track.where(number: nil).each do |track|
      track.update! number: format_number(track.name)
    end
  end

  def unchecked_releases
    Release.includes([:sfv_files, :tracks])
      .where(last_verified_at: nil)
      .select { |release| !release.details.has_key?(:sfv) }
  end

  def check_sfv release
    return if release.last_verified_at || release.details[:sfv]
    results = release.sfv_files.collect &:check
    if results.all? { |result| result == :ok }
      release.details.delete(:sfv) if release.details.has_key?(:sfv)
      release.update!(last_verified_at: Time.now) if !release.last_verified_at
    else
      release.details[:sfv] = results
      release.save!
    end
  end
end
