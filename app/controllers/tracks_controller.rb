class TracksController < ApplicationController
  def show
    track = Track.find(params[:id]).decorate
    if track.file
      response = { id: track.id, url: track.url }
    else
      track.update! process_id: LameWorker.perform_async(track.id) if !track.process_id
      response = { id: track.id }
    end
    respond_to do |format|
      format.json do
        render json: response.to_json, layout: false, status: 200
      end
    end
  end
end