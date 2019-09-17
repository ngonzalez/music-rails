class StreamsController < ApplicationController
  before_action :set_track
  before_action :set_stream_id
  before_action :create_stream

  def create
    respond_to do |format|
      format.json do
        render json: if stream_ready?
          { stream_url: "http://#{HOST_NAME}/hls/#{@stream_uuid}.m3u8" }
        else
          { stream_uuid: @stream_uuid }
        end.to_json,
          layout: false
      end
    end
  end

  private

  def set_track
    @track = Track.find params[:track_id]
  end

  def set_stream_id
    @stream_uuid = params[:stream_uuid] || UUID.new.generate
  end

  def stream_ready?
    File.exists? "#{HLS_FOLDER}/#{@stream_uuid}.m3u8" rescue false
  end

  def create_stream
    if !redis_db.get 'streams:%s' % @stream_uuid
      redis_db.setex 'streams:%s' % @stream_uuid, 120, 1
      StreamWorker.perform_async @track.id, @stream_uuid
    end
  end

end
