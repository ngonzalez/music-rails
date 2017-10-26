class StreamsController < ApplicationController
  def show
    track = Track.find params[:id]
    stream_uuid = UUID.new.generate
    StreamWorker.perform_async(track.id, stream_uuid)
    respond_to do |format|
      format.json do
        render json: {
          stream_uuid: stream_uuid
        }.to_json, layout: false, status: 200
      end
    end
  end
  def create
    stream_uuid = params[:stream_uuid]
    file_exists = begin
      File.exists? "/tmp/hls/#{stream_uuid}.m3u8"
    rescue
      false
    end
    respond_to do |format|
      format.json do
        render json: if file_exists
            { stream_url: "http://#{HOST_NAME}/hls/#{stream_uuid}.m3u8" }
          else
            { error: 'not found' }
          end.to_json, layout: false, status: 200
      end
    end
  end
end