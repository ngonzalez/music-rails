module TaskHelpers
  def clear_deleted_folders
    (Release.pluck(:folder).uniq - FOLDERS - FOLDERS_WITH_SUBFOLDERS).each do |folder|
      Release.where(folder: folder).destroy_all
    end
  end

  def update_releases
    Release.find_each do |release|
      update_release_path release
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
    update_releases_folder_dates
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

  def update_releases_folder_dates
    Release.find_each do |release|
      f = File::Stat.new release.decorate.public_path
      if f.birthtime != release.folder_created_at || f.mtime != release.folder_updated_at
        release.update! folder_created_at: f.birthtime, folder_updated_at: f.mtime
      end
    end
  end

  def update_releases_format_name
    Release.where(format_name: nil).each do |release|
      release.update! format_name: get_format_from_release_name(release) || format_track_format(release)
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
      release.tracks.each{|track| track.update! format_name: format_track_format(release) }
    end
  end

  def update_tracks_number
    Track.where(number: nil).each do |track|
      track.update! number: format_number(track.name)
    end
  end

  def year_from_name name
    res = name.split("-").select{|item| item.match(/(\d{4})/) }.last
    res = '1999' if ['199','99','19'].include?(res)
    res = '2000' if res == '200'
    return res
  end

  def format_number name
    name.split("-").length > 2 ? name.split("-")[0] : name.split("_")[0]
  end

  def format_name name
    year = year_from_name name
    array = name.gsub("_-_", "-").gsub("(", "").gsub(")", "").gsub(".", "").split("-")
    array -= ALLOWED_SOURCES
    array -= ["Promo_CD", "Promo_CDS", "VA", "CDS", "WAV", "FLAC", "AIFF", "ALAC"]
    array.reject! &:blank?
    array.each_with_object([]){|string, array|
      next if array.include? year
      array << string.gsub("_", " ")
    }.join(" ")
  end

  def format_track_format release
    return if release.tracks.empty?
    case release.tracks[0].format_info
      when /FLAC/ then "FLAC"
      when /MPEG ADTS, layer III, v1, 192 kbps/ then "MP3-192CBR"
      when /MPEG ADTS, layer III, v1, 256 kbps/ then "MP3-256CBR"
      when /MPEG ADTS, layer III, v1, 320 kbps/ then "MP3-320CBR"
      when /MPEG ADTS, layer III|MPEG ADTS, layer II|Audio file with ID3/
        case release.tracks.map(&:bitrate).sum.to_f / release.tracks.length
          when 192.0 then "MP3-192CBR"
          when 256.0 then "MP3-256CBR"
          when 320.0 then "MP3-320CBR"
          else "MP3"
        end
      when /WAVE audio/ then "WAV"
      when /iTunes AAC/ then "iTunes AAC"
      when /MPEG v4/ then "MPEG4"
      when /clip art|BINARY|data/ then get_format_from_release_name(release) || "DATA"
    end
  end

  def get_format_from_release_name release
    case release.name
      when /\-FLAC\-/ then "FLAC"
      when /\-ALAC\-/ then "ALAC"
      when /\-WAV\-/ then "WAV"
      when /\-AIFF\-/ then "AIFF"
    end
  end

  def unchecked_releases
    Release.joins(:sfv_files).merge(SfvFile.local).where(last_verified_at: nil).select { |release| !release.details.has_key?(:sfv) }
  end

  def run_check_sfv release, sfv_file
    m3u_file = find_m3u release, sfv_file
    return :failed if !m3u_file
    files_count = m3u_file.decorate.file_names.length
    case Dir.chdir([release.decorate.public_path, sfv_file.base_path].join('/')) { %x[cfv -f #{sfv_file.file.path}] }
      when /#{files_count} files, #{files_count} OK/ then :ok
      when /badcrc/ then :bad_crc
      when /chksum file errors/ then :chksum_file_errors
      when /not found|No such file/ then :missing_files
    end
  end

  def find_m3u release, sfv_file
    m3u_file = release.m3u_files.local.select { |item| item.file_name =~ /^0{2,3}/ }.detect { |item| item.base_path.try(:downcase) == sfv_file.base_path.try(:downcase) }
    m3u_file = release.m3u_files.local.select { |item| item.file_name =~ /0{2,3}/  }.detect { |item| item.base_path.try(:downcase) == sfv_file.base_path.try(:downcase) } if !m3u_file
    m3u_file = release.m3u_files.local.detect { |item| item.base_path.try(:downcase) == sfv_file.base_path.try(:downcase) } if !m3u_file
    return m3u_file
  end

  def check_sfv release, source=nil
    key = source ? "#{source.downcase}_sfv".to_sym : :sfv
    field_name = source ? "#{source.downcase}_last_verified_at".to_sym : :last_verified_at
    return if release.send(field_name) || release.details[key]
    results = release.sfv_files.where(source: source).each_with_object([]){ |sfv_file, array| array << run_check_sfv(release, sfv_file) }
    if results.all? { |result| result == :ok }
      release.details.delete(key) if release.details.has_key?(key)
      release.update!(field_name => Time.now) if !release.send(field_name)
    else
      release.details[key] = results
      release.save!
    end
  end

end
