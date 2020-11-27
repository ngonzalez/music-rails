class AudioFilesController < ApplicationController
  before_action :set_audio_file
  before_action :set_audio_file_m3u8_exists
  before_action :create_file
  before_action :create_m3u8

  def show
    respond_to do |format|
      format.json do
        render json: @audio_file.to_json,
          layout: false
      end
    end
  end

    private

  def set_audio_file
    @audio_file = AudioFile.find_by(data_url: params[:id]).decorate
  end

  def set_audio_file_m3u8_exists
    @audio_file.m3u8_exists = File.exists? "#{HLS_FOLDER}/#{@audio_file.id}.m3u8" rescue false
  end

  def create_file
    if !@audio_file.file && !RedisDb.client.get("encode:#{@audio_file.id}")
      RedisDb.client.setex "encode:#{@audio_file.id}", 120, 1
      EncodeWorker.perform_async @audio_file.id
    end
  end

  def create_m3u8
    if @audio_file.file && !@audio_file.m3u8_exists && !RedisDb.client.get("stream:#{@audio_file.id}")
      RedisDb.client.setex "stream:#{@audio_file.id}", 120, 1
      StreamWorker.perform_async @audio_file.id, @audio_file.file.path
    end
  end

end
