class StreamWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  def perform track_id
    track = Track.find track_id
    `ln -s #{track.file.path} #{HLS_FOLDER}/#{track.id}.#{DEFAULT_ENCODING}`
    `mediafilesegmenter -b http://#{HOST_NAME}/hls -f #{HLS_FOLDER} #{HLS_FOLDER}/#{track.id}.#{DEFAULT_ENCODING} -B #{track.id} -i #{track.id}.m3u8`
  rescue Exception => e
    Rails.logger.error e.inspect
  ensure
    `rm #{HLS_FOLDER}/#{track.id}.#{DEFAULT_ENCODING}`
  end
end
