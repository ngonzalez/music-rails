class EncodeWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => true, :backtrace => true

  def perform audio_file_id
    audio_file = AudioFile.find(audio_file_id).decorate
    return if audio_file.file
    file = Down.download "http://#{BACKUP_SERVER_HOST}:#{BACKUP_SERVER_PORT}#{BACKUP_SERVER_PATH}/#{audio_file.path}"
    temp_file = '/tmp/%s.%s' % [audio_file.id, audio_file.format_name.downcase]
    strip_metadata file.path, temp_file if ['AAC', 'ALAC', 'MP3'].include? audio_file.format_name
    encode file.path, temp_file if ['AIFF', 'WAV'].include? audio_file.format_name
    audio_file.update! file: File.open(temp_file)
    FileUtils.rm_f temp_file
  rescue => exception
    Rails.logger.error exception
  end

    private

  def strip_metadata source, destination
    `ffmpeg -y -i #{source} -map 0:a -codec:a copy -map_metadata -1 #{destination} -nostats -loglevel 0`
  end

  def encode source, destination
    `lame --silent -b 320 -ms #{source} #{destination}`
  end

end
