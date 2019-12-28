class TracksController < ApplicationController
  before_action :set_track
  before_action :create_file
  before_action :create_m3u8

  def show
    respond_to do |format|
      format.json do
        render json: @track.decorate.details.marshal_dump.to_json,
          layout: false
      end
    end
  end

  private

  def set_track
    @track = Track.find params[:id]
  end

  def create_file
    if !@track.file && !redis_db.get("tracks:#{@track.id}")
      redis_db.setex "tracks:#{@track.id}", 120, 1
      LameWorker.perform_async @track.id
    end
  end

  def create_m3u8
    if @track.file && !@track.decorate.m3u8_exists? && !redis_db.get("streams:#{@track.id}")
      redis_db.setex "streams:#{@track.id}", 120, 1
      StreamWorker.perform_async @track.id, @track.file.path
    end
  end
end
