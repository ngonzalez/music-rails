class TracksController < ApplicationController
  def show
    track = Track.find params[:id]
    response = { id: track.id }
    if track.file
      response.merge! media_url: track.decorate.media_url
    elsif !redis_db.get 'tracks:%s' % track.id
      redis_db.setex 'tracks:%s' % track.id, 120, 1
      LameWorker.perform_async(track.id)
    end
    respond_to do |format|
      format.json do
        render json: response.to_json, layout: false, status: 200
      end
    end
  end
end