class TracksController < ApplicationController
  def show
    track = Track.find params[:id]
    response = { id: track.id }
    if track.file
      response.merge! media_url: track.decorate.media_url
    elsif !redis_db.get 'stream:%s' % track.id
      LameWorker.perform_async(track.id)
    end
    respond_to do |format|
      format.json do
        render json: response.to_json, layout: false, status: 200
      end
    end
  end

  private
  def redis_db
    @redis_db ||= Redis.new host: '127.0.0.1', port: 6379, db: 0
  end
end