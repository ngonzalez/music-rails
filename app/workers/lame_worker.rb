class LameWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  def perform track_id
    track = Track.find track_id
    begin
      if !track.state && !track.encoded_file
        track.update!(state: "processing")
        file_path = PUBLIC_PATH + track.decorate.file_url
        if track.format_name == "FLAC"
          temp_file_flac = "/tmp/#{track.id}.flac"
          temp_file_wav = "/tmp/#{track.id}.wav"
          `cp #{Shellwords.escape(file_path)} #{temp_file_flac}`
          `flac -d -f #{temp_file_flac}`
        end
        destination_file = "/tmp/#{track.id}.mp3"
        encode temp_file_wav || file_path, destination_file
        track.update!(state: "ready", encoded_file: File.open(destination_file))
        FileUtils.rm_f destination_file
        FileUtils.rm_f temp_file_wav if temp_file_wav
        FileUtils.rm_f temp_file_flac if temp_file_flac
      end
    rescue Exception => e
      puts e.inspect
      track.update! state: nil
    end
  end

  def encode source, destination
    `lame -S -V0 #{Shellwords.escape(source)} #{destination}`
  end

end