class StreamWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  def default_encoding
    ALLOWED_AUDIO_FORMATS.deep_symbolize_keys.flat_map { |_, format| format[:extensions] if format[:default] }.compact.pop
  end

  def perform audio_file_id, file_path
    `ln -s #{file_path} #{HLS_FOLDER}/#{audio_file_id}.#{default_encoding}`
    `mediafilesegmenter -b http://#{HOST_NAME}/hls -f #{HLS_FOLDER} #{HLS_FOLDER}/#{audio_file_id}.#{default_encoding} -B #{audio_file_id} -i #{audio_file_id}.m3u8`
  rescue Exception => e
    Rails.logger.error e.inspect
  ensure
    `rm #{HLS_FOLDER}/#{audio_file_id}.#{default_encoding}`
  end

end
