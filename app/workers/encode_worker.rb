require 'down'

class EncodeWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  def perform audio_file_id
    audio_file = AudioFile.find(audio_file_id).decorate
    return if audio_file.file
    file = Down.download "http://#{HOST_NAME}#{BASE_PATH}/#{audio_file.path}"
    temp_file = '/tmp/%s.%s' % [audio_file.id, audio_file.format_name.downcase]
    strip_metadata file.path, temp_file if ['AAC', 'ALAC', 'MP3'].include? audio_file.format_name
    encode file.path, temp_file if ['AIFF', 'WAV'].include? audio_file.format_name
    audio_file.update! file: File.open(temp_file)
    FileUtils.rm_f temp_file
  end

    private

  def strip_metadata source, destination
    `ffmpeg -i #{source} -map 0:a -codec:a copy -map_metadata -1 #{destination} -nostats`
  end

  def encode source, destination
    `ffmpeg -i #{source} -c:a aac -strict -2 #{destination}`
  end

end
