class StreamWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  def perform track_id, stream_uuid
    track = Track.find track_id
    `ln -s #{track.file.path} #{HLS_FOLDER}/#{stream_uuid}.#{DEFAULT_ENCODING}`
    `mediafilesegmenter -b http://#{HOST_NAME}/hls -f #{HLS_FOLDER} #{HLS_FOLDER}/#{stream_uuid}.#{DEFAULT_ENCODING} -B #{stream_uuid} -i #{stream_uuid}.m3u8`
  rescue Exception => e
    Rails.logger.info e.inspect
  ensure
    `rm #{HLS_FOLDER}/#{stream_uuid}.#{DEFAULT_ENCODING}`
  end

end