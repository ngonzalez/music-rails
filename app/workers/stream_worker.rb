class StreamWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => true, :backtrace => true

  def perform audio_file_id, file_path
    `ffmpeg -y \
    -i #{file_path} \
    -codec copy \
    -loglevel 0 \
    -map 0 \
    -f hls \
    -hls_time 10 \
    -hls_playlist_type vod \
    -hls_segment_filename "#{APP_SERVER_TMP_PATH}/#{audio_file_id}_%d.ts" \
    "#{APP_SERVER_TMP_PATH}/#{audio_file_id}.m3u8"`

    RedisDb.client.set "m3u8:#{audio_file_id}", 1
  rescue => exception
    Rails.logger.error exception
  end

end
