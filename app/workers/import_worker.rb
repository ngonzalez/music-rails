class ImportWorker

  require Rails.root + "lib/helpers/import_helpers"

  include ImportHelpers

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  attr_accessor :release

  def initialize options={}
    ensure_db_connection
    set_release options
  end

  def ensure_db_connection
    track = nil
    loop do
      begin
        track = Track.take
      rescue
        Rails.logger.info "\sImportWorker: DB Busy, Retrying.."
        sleep 1
      end
      break if !track.nil?
    end
  end

  def set_release options
    @release = Release.create! options.slice(*[:name, :folder, :subfolder, :source])
  end

  def perform
    import_tracks
    import_images
    import_nfo
    import_sfv
    import_m3u
  end

  def import_tracks
    ALLOWED_AUDIO_FORMATS.each do |format|
      list_files(release, format) do |path, file_name|
        next if release.tracks.detect { |track| track.name == file_name }
        create_track release, path, file_name
      end
    end
  end
  def import_images
    ALLOWED_IMAGE_FORMATS.each do |format|
      list_files(release, format) do |path, file_name|
        next if release.images.detect { |image| image.file_name == file_name }
        create_image release, path, file_name
      end
    end
  end
  def import_nfo
    list_files(release, NFO_TYPE) do |path, file_name|
      next if release.nfo_files.detect { |nfo| nfo.file_name == file_name }
      create_nfo release, path, file_name
    end
  end
  def import_sfv
    list_files(release, SFV_TYPE) do |path, file_name|
      next if release.sfv_files.local.detect { |sfv| sfv.file_name == file_name }
      import_file release, :sfv_files, path, file_name
    end
  end
  def import_m3u
    list_files(release, M3U_TYPE) do |path, file_name|
      next if release.m3u_files.local.detect { |m3u| m3u.file_name == file_name }
      import_file release, :m3u_files, path, file_name
    end
  end
end