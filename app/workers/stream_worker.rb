class StreamWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  def perform audio_file_id, file_path
    `ffmpeg -y \
     -i #{file_path} \
     -codec copy \
     -map 0 \
     -loglevel 0 \
     -f segment \
     -segment_time 10 \
     -segment_format mpegts \
     -segment_list "#{HLS_FOLDER}/#{audio_file_id}.m3u8" \
     -segment_list_type m3u8 \
     "#{HLS_FOLDER}/#{audio_file_id}_%d.ts"`
  end

end
