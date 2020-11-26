class ImportWorker
  require Rails.root + "lib/helpers/import_helpers"
  include ImportHelpers

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  attr_accessor :music_folder

  def initialize options={}
    @music_folder = MusicFolder.create! options.slice(*[:name, :folder, :subfolder, :source])
    f = File::Stat.new music_folder.decorate.public_path
    music_folder.update! folder_created_at: f.birthtime, folder_updated_at: f.mtime
  end

  def perform
    ALLOWED_AUDIO_FORMATS.flat_map { |_, format| format[:extensions] }.each do |format|
      list_files(music_folder.decorate.public_path, format) do |path, file_name|
        next if music_folder.audio_files.detect { |audio_file| audio_file.name == file_name }
        begin
          create_audio_file music_folder, path, file_name
        rescue => e
          Rails.logger.error e
          next
        end
      end
    end

    ALLOWED_IMAGE_FORMATS.flat_map { |_, format| format[:extensions] }.each do |format|
      list_files(music_folder.decorate.public_path, format) do |path, file_name|
        next if music_folder.images.detect { |image| image.file_name == file_name }
        begin
          create_image music_folder, path, file_name
        rescue => e
          Rails.logger.error e
          next
        end
      end
    end

    list_files(music_folder.decorate.public_path, "m3u") do |path, file_name|
      next if music_folder.m3u_files.detect { |m3u| m3u.file_name == file_name }
      begin
        import_file music_folder, :m3u_files, path, file_name
      rescue => e
        Rails.logger.error e
        next
      end
    end
  end

end
