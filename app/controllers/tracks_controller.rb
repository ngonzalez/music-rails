class TracksController < ApplicationController
  def show
    track = Track.find(params[:id]).decorate
    if ["wav", "aiff", "flac"].include? track.file_extension
      case track.state
        when "processing"
          response = { state: track.state }
        when "ready"
          response = { url: track.encoded_file.url.gsub(track.file_extension, "mp3") }
        else
          response = { id: LameWorker.perform_async(track.id) }
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