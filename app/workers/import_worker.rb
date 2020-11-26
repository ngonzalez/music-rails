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

    ALLOWED_FILE_FORMATS.flat_map { |_, format| format[:extensions] }.each do |format|
      list_files(music_folder.decorate.public_path, format) do |path, file_name|
        next if music_folder.send("#{format}_files".to_sym).detect { |item| item.file_name == file_name }
        begin
          import_file music_folder, "#{format}_files".to_sym, path, file_name
        rescue => e
          Rails.logger.error e
          next
        end
      end
    end

  end

end
