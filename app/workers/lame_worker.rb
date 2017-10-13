class LameWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  def perform track_id
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
    begin
      if !track.file
        if ["iTunes AAC", "ALAC"].include?(track.format_name) || track.format_name =~ /MP3/
          track.update! file: File.open(track.decorate.public_path)
        elsif ["FLAC"].include? track.format_name
          file_path = Shellwords.escape track.decorate.public_path
          temp_file_flac = "/tmp/#{track.id}.flac"
          temp_file_wav = "/tmp/#{track.id}.wav"
          copy_file file_path, temp_file_flac
          decode_file temp_file_flac
          temp_file = "/tmp/#{track.id}.#{DEFAULT_ENCODING}"
          encode temp_file_wav, temp_file
          track.update! file: File.open(temp_file)
        elsif ["WAV", "AIFF"].include? track.format_name
          file_path = Shellwords.escape track.decorate.public_path
          temp_file = "/tmp/#{track.id}.#{DEFAULT_ENCODING}"
          encode file_path, temp_file
          track.update! file: File.open(temp_file)
        end
      end
    rescue Exception => e
      Rails.logger.info e.inspect
    ensure
      track.update! process_id: nil
      FileUtils.rm_f temp_file if temp_file && File.exists?(temp_file)
      FileUtils.rm_f temp_file_wav if temp_file_wav && File.exists?(temp_file_wav)
      FileUtils.rm_f temp_file_flac if temp_file_flac && File.exists?(temp_file_flac)
    end
  end

  def encode source, destination
    case DEFAULT_ENCODING
      when "mp3"
        `lame -S -b 320 -ms #{source} #{destination}`
      when "aac"
        `ffmpeg -i #{source} -c:a aac -strict -2 #{destination}`
    end
  end

  def copy_file source, destination
    `cp #{source} #{destination}`
  end

  def decode_file source
    `flac -d -f #{source}`
  end

end