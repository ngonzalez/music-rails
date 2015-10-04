class LameWorker
  include Sidekiq::Worker
  def perform track_id
    track = Track.find track_id
    return if track.state
    track.update!(state: "processing")
    track.update!(file: File.open(PUBLIC_PATH + track.decorate.file_url)) if !track.file
    track.update!(encoded_file: track.file.lame_encoder) if !track.encoded_file
    track.update!(state: "ready")
    true
  end
end