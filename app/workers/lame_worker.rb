class LameWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :default, :retry => false, :backtrace => true
  def perform track_id
    track = Track.find track_id
    if !track.state && !track.encoded_file
      track.update!(state: "processing")
      # track.file = File.open(PUBLIC_PATH + track.decorate.file_url)
      # track.update!(encoded_file: track.file.lame_encoder)
      `lame -S -V0 #{Shellwords.escape(PUBLIC_PATH + track.decorate.file_url)} /tmp/#{track.id}.mp3`
      track.update!(state: "ready", encoded_file: File.open("/tmp/#{track.id}.mp3"))
      FileUtils.rm_f "/tmp/#{track.id}.mp3"
    end
  end
end