class TracksController < ApplicationController
  def show
    track = Track.find(params[:id]).decorate
    if track.file
      response = { id: track.id, url: track.url }
    else
      if track.processing?
        response = { state: track.state }
      elsif !track.state
        track.update! state: "processing"
        response = { id: LameWorker.perform_async(track.id) }
      end
    end
    respond_to do |format|
      format.json do
        render json: response.to_json, layout: false, status: 200
      end
    end
  end
end