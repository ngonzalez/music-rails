class TracksController < ApplicationController
  before_action :set_track
  before_action :set_track_m3u8_exists
  before_action :create_file
  before_action :create_m3u8

  def show
    respond_to do |format|
      format.json do
        render json: @track.to_json,
          layout: false
      end
    end
  end

  private

  def set_track
    @track = Track.find(params[:id]).decorate
  end

  def set_track_m3u8_exists
    @track.m3u8_exists = File.exists? @track.m3u8_path rescue false
  end

  def create_file
    if !@track.file && !RedisDb.client.get("tracks:#{@track.id}")
      RedisDb.client.setex "tracks:#{@track.id}", 120, 1
      LameWorker.perform_async @track.id
    end
  end

  def create_m3u8
    if @track.file && !@track.m3u8_exists && !RedisDb.client.get("streams:#{@track.id}")
      RedisDb.client.setex "streams:#{@track.id}", 120, 1
      StreamWorker.perform_async @track.id, @track.file.path
    end
  end
end
