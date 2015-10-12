class TracksController < ApplicationController
  def show
    track = Track.find(params[:id]).decorate
    response = { id: track.id }
    if track.file
      response.merge! media_url: track.media_url
    elsif !track.process_id
      track.update! process_id: LameWorker.perform_async(track.id)
    end
    respond_to do |format|
      format.json do
        render json: response.to_json, layout: false, status: 200
      end
    end
  end
end