class ImportWorker
  require Rails.root + "lib/helpers/import_helpers"
  include ImportHelpers

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  attr_accessor :folder

  def initialize options={}
    set_folder options
  end

  def set_folder options
    @folder = Folder.create! options.slice(*[:name, :folder, :subfolder, :source])
    f = File::Stat.new folder.decorate.public_path
    folder.update! folder_created_at: f.birthtime, folder_updated_at: f.mtime
  rescue Exception => exception
    Rails.logger.error exception
  end

  def perform
    import_audio_files
    import_images
    import_m3u_files
  rescue Exception => exception
    Rails.logger.error exception
  end

  def import_audio_files
    ALLOWED_AUDIO_FORMATS.flat_map { |_, format| format[:extensions] }.each do |format|
      list_files(folder.decorate.public_path, format) do |path, file_name|
        next if folder.tracks.detect { |track| track.name == file_name }
        create_track folder, path, file_name
      end
    end
  end
  def import_images
    ALLOWED_IMAGE_FORMATS.flat_map { |_, format| format[:extensions] }.each do |format|
      list_files(folder.decorate.public_path, format) do |path, file_name|
        next if folder.images.detect { |image| image.file_name == file_name }
        create_image folder, path, file_name
      end
    end
  end
  def import_m3u_files
    list_files(folder.decorate.public_path, "m3u") do |path, file_name|
      next if folder.m3u_files.detect { |m3u| m3u.file_name == file_name }
      import_file folder, :m3u_files, path, file_name
    end
  end
end
