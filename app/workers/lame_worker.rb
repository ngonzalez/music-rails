class LameWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  def perform audio_file_id
    audio_file = AudioFile.find(audio_file_id).decorate
    return if audio_file.file
    file_path = Shellwords.escape audio_file.decorate.public_path
    temp_file = '/tmp/%s.%s' % [audio_file.id, default_encoding]
    if ['AAC', 'ALAC', 'MP3'].include? audio_file.format_name
      strip_metadata file_path, temp_file
    elsif ['AIFF', 'WAV'].include? audio_file.format_name
      encode file_path, temp_file
    end
    audio_file.update! file: File.open(temp_file)
  ensure
    FileUtils.rm_f temp_file if temp_file && File.exists?(temp_file)
  end

    private

  def default_encoding
    ALLOWED_AUDIO_FORMATS.deep_symbolize_keys.flat_map { |_, format| format[:extensions] if format[:default] }.compact.pop
  end

  def strip_metadata source, destination
    `ffmpeg -i #{source} -map 0:a -codec:a copy -map_metadata -1 #{destination} -nostats -loglevel 0`
  end

  def encode source, destination
    `ffmpeg -i #{source} -c:a aac -strict -2 #{destination}`
  end

end
