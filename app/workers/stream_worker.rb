class StreamWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  def perform track_id, track_file_path
    `ln -s #{track_file_path} #{HLS_FOLDER}/#{track_id}.#{DEFAULT_ENCODING}`
    `mediafilesegmenter -b http://#{HOST_NAME}/hls -f #{HLS_FOLDER} #{HLS_FOLDER}/#{track_id}.#{DEFAULT_ENCODING} -B #{track_id} -i #{track_id}.m3u8`
  rescue Exception => e
    Rails.logger.error e.inspect
  ensure
    `rm #{HLS_FOLDER}/#{track_id}.#{DEFAULT_ENCODING}`
  end
end
