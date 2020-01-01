class ImportWorker
  require Rails.root + "lib/helpers/import_helpers"
  include ImportHelpers

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  attr_accessor :release

  def initialize options={}
    set_release options
  end

  def set_release options
    @release = Release.create! options.slice(*[:name, :folder, :subfolder, :source])
    f = File::Stat.new release.decorate.public_path
    release.update! folder_created_at: f.birthtime, folder_updated_at: f.mtime
  rescue Exception => exception
    Rails.logger.error exception
  end

  def perform
    import_tracks
    import_images
    import_nfo
    import_sfv
    import_m3u
  rescue Exception => exception
    Rails.logger.error exception
  end

  def import_tracks
    ALLOWED_AUDIO_FORMATS.flat_map { |_, format| format[:extensions] }.each do |format|
      list_files(release.decorate.public_path, format) do |path, file_name|
        next if release.tracks.detect { |track| track.name == file_name }
        create_track release, path, file_name
      end
    end
  end
  def import_images
    ALLOWED_IMAGE_FORMATS.flat_map { |_, format| format[:extensions] }.each do |format|
      list_files(release.decorate.public_path, format) do |path, file_name|
        next if release.images.detect { |image| image.file_name == file_name }
        create_image release, path, file_name
      end
    end
  end
  def import_nfo
    list_files(release.decorate.public_path, "nfo") do |path, file_name|
      next if release.nfo_files.detect { |nfo| nfo.file_name == file_name }
      create_nfo release, path, file_name
    end
  end
  def import_sfv
    list_files(release.decorate.public_path, "sfv") do |path, file_name|
      next if release.sfv_files.detect { |sfv| sfv.file_name == file_name }
      import_file release, :sfv_files, path, file_name
    end
  end
  def import_m3u
    list_files(release.decorate.public_path, "m3u") do |path, file_name|
      next if release.m3u_files.detect { |m3u| m3u.file_name == file_name }
      import_file release, :m3u_files, path, file_name
    end
  end
end