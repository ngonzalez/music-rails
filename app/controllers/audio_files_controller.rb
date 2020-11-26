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
    @audio_file = AudioFile.friendly.find(params[:id]).decorate
  end

  def set_audio_file_m3u8_exists
    @audio_file.m3u8_exists = File.exists? @audio_file.m3u8_path rescue false
  end

  def create_file
    if !@audio_file.file && !RedisDb.client.get("audio_file:#{@audio_file.id}")
      RedisDb.client.setex "audio_file:#{@audio_file.id}", 120, 1
      LameWorker.perform_async @audio_file.id
    end
  end

  def create_m3u8
    if @audio_file.file && !@audio_file.m3u8_exists && !RedisDb.client.get("streams:#{@audio_file.id}")
      RedisDb.client.setex "streams:#{@audio_file.id}", 120, 1
      StreamWorker.perform_async @audio_file.id, @audio_file.file.path
    end
  end

end
