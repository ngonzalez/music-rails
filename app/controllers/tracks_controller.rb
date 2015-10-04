class TracksController < ApplicationController
  def show
    track = Track.find(params[:id]).decorate
    if ["wav", "aiff", "flac"].include? track.file_extension
      if track.state == "processing"
        response = { state: track.state }
      else
        if track.encoded_file
          response = { url: track.encoded_file.url }
        elsif !track.state
          response = { id: LameWorker.perform_async(track.id) }
        end
      end
    else
      response = { url: track.file_url }
    end
    respond_to do |format|
      format.json do
        render json: response.to_json, layout: false, status: 200
      end
    end
  end
end