class StreamWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => true, :backtrace => true

  def perform audio_file_id, file_path
    `ffmpeg -y \
     -i #{file_path} \
     -codec copy \
     -map 0 \
     -loglevel 0 \
     -f segment \
     -segment_time 10 \
     -segment_format mpegts \
     -segment_list "#{APP_SERVER_TMP_PATH}/#{audio_file_id}.m3u8" \
     -segment_list_type m3u8 \
     "#{APP_SERVER_TMP_PATH}/#{audio_file_id}_%d.ts"`

     RedisDb.client.set "m3u8:#{audio_file_id}", 1
   rescue => exception
     Rails.logger.error exception
  end

end
