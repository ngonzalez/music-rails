class LameWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :default, :retry => true, :backtrace => true
  def perform track_id
    puts " => Processing Track: #{track_id} 0"
    track = Track.find track_id
    return if track.state
    puts " => Processing Track: #{track_id} 1"
    track.update!(state: "processing")
    track.update!(file: File.open(PUBLIC_PATH + track.decorate.file_url)) if !track.file
    track.update!(encoded_file: track.file.lame_encoder) if !track.encoded_file
    track.update!(state: "ready")
    true
  end
end