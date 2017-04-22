require Rails.root + "lib/scene_helpers"

# Import srrDB SFV
releases = Release.without_srrdb_sfv_file \
  .select { |release| !release.details.has_key?(:srrdb_sfv) } \
  .select { |release| !release.name.match(EXCEPT_GRPS) } \
  .select(&:scene?) \
  .take 200

releases.each do |release|
  begin
    ImportWorker.new(name: release.name).import_srrdb_sfv
  rescue SrrdbLimitReachedError => e
    Rails.logger.info e
    break
  end
end

# Missing Files
array = []
Release.includes([:m3u_files, :tracks]).each do |release|
  if release.missing_files.any?
    array << release
  end
end ; puts "%s items found" % [ array.length ]

# Missing NFO
releases = Release.includes(:images) \
                  .without_nfo_files \
                  .select { |release| !release.name.match(EXCEPT_GRPS) } \
                  .select(&:scene?)

# Clear Tracks
desc "clear tracks"
task clear_tracks: :environment do
  Track.update_all file_uid: nil, file_name: nil, process_id: nil
  FileUtils.rm_rf Rails.root + "public/system/dragonfly/tracks"
  FileUtils.rm_rf "/tmp/dragonfly"
  Rails.cache.clear
end

# Clear Empty Files
desc "clear local files"
task clear_local_files: :environment do
  NfoFile.select{ |nfo_file| !nfo_file.file_exists? }.each &:destroy
  M3uFile.select{ |m3u_file| !m3u_file.file_exists? }.each &:destroy
  SfvFile.select{ |sfv_file| !sfv_file.file_exists? }.each &:destroy
end
