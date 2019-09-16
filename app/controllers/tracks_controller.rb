class TracksController < ApplicationController
  before_action :set_track, only: [:show]
  before_action :encode_track, only: [:show]

  def show
    respond_to do |format|
      format.json do
        render json: @track.decorate.details.to_json,
          layout: false
      end
    end
  end

  private

  def set_track
    @track = Track.find params[:id]
  end

  def encode_track
    if !@track.file && !redis_db.get('tracks:%s' % @track.id)
      redis_db.setex 'tracks:%s' % @track.id, 120, 1
      LameWorker.perform_async @track.id
    end
  end
end
