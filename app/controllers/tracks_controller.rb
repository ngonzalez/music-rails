class TracksController < ApplicationController
  def show
    track = Track.find(params[:id]).decorate
    if track.streamable?
      response = { url: track.file_url }
    else
      if track.processing?
        response = { state: track.state }
      elsif !track.state
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