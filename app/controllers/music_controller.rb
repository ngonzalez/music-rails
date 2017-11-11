class MusicController < ApplicationController

  require Rails.root.join "lib/helpers/search_helpers"
  include SearchHelpers

  def index
    respond_to do |format|
      format.html do
        render nothing: true
      end
      format.json do
        render json: {}.to_json,
          layout: false, status: 200
      end
    end
  end

  def show
    set_release
    set_tracks
    respond_to do |format|
      format.html
      format.json do
        render json: {
          release: @release,
          tracks: @tracks
        }.to_json, layout: false, status: 200
      end
    end
  end

  def search
    @t1 = Time.now
    search_releases
    respond_to do |format|
      format.html
      format.json do
        render json: @releases.to_json,
          layout: false, status: 200
      end
    end
  end

  private

  def set_release
    @release = Release.friendly.find(params[:id]).decorate
  end

  def set_tracks
    @tracks = @release.tracks.decorate.sort { |a, b| a.number <=> b.number }
  end

  def search_releases
    @releases = search_db params.slice(:q, :subfolder)
  end
end