class TracksController < ApplicationController
  def show
    track = Track.find(params[:id]).decorate
    if track.streamable?
      track.update!(file: File.open(PUBLIC_PATH + track.file_url)) if !track.file
      response = { id: track.id, url: track.encoded_file ? track.encoded_file.url : track.file.url }
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