class LameWorker

  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => false, :backtrace => true

  def perform track_id
    track = Track.find track_id
    redis_db.setex 'stream:%s' % track.id, 120, 1
    if !track.file
      if track.format_name =~ /MP3/ || ["iTunes AAC", "ALAC"].include?(track.format_name)
        file_path = Shellwords.escape track.decorate.public_path
        temp_file = "/tmp/#{track.id}.#{DEFAULT_ENCODING}"
        strip_metadata file_path, temp_file
        track.update! file: File.open(temp_file)
      elsif ["FLAC"].include? track.format_name
        file_path = Shellwords.escape track.decorate.public_path
        temp_file = "/tmp/#{track.id}.#{DEFAULT_ENCODING}"
        temp_file_flac = "/tmp/#{track.id}.flac"
        temp_file_wav = "/tmp/#{track.id}.wav"
        copy_file file_path, temp_file_flac
        decode_file temp_file_flac
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
    redis_db.del 'stream:%s' % track.id
    FileUtils.rm_f temp_file if temp_file && File.exists?(temp_file)
    FileUtils.rm_f temp_file_wav if temp_file_wav && File.exists?(temp_file_wav)
    FileUtils.rm_f temp_file_flac if temp_file_flac && File.exists?(temp_file_flac)
  end

  private
  def redis_db
    @redis_db ||= Redis.new host: '127.0.0.1', port: 6379, db: 0
  end

  def strip_metadata source, destination
    `ffmpeg -i #{source} -map 0:a -codec:a copy -map_metadata -1 #{destination} -nostats -loglevel 0`
  end

  def encode source, destination
    case DEFAULT_ENCODING
      when "mp3"
        `lame --silent -b 320 -ms #{source} #{destination}`
      when "aac"
        `ffmpeg -i #{source} -c:a aac -strict -2 #{destination}`
    end
  end

  def copy_file source, destination
    `cp #{source} #{destination}`
  end

  def decode_file source
    `flac -d -s -f #{source}`
  end
end