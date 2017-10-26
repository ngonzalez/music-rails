class StreamWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  def perform track_id, stream_uuid
    track = nil
    loop do
      begin
        track = Track.find track_id
      rescue
        Rails.logger.info "\sLameWorker: DB Busy, Retrying.."
        sleep 1
      end
      break if !track.nil?
    end
    `ffmpeg -re -i #{track.file.path} -c copy -f flv rtmp://#{INTERNAL_IP}/hls/#{stream_uuid} -nostats -loglevel 0`
    return true
  end

end