class MusicController < ApplicationController

  def index
    get_releases
    respond_to do |format|
      format.json do
        render json: @releases.to_json
      end
    end
  end

  def show
    get_release
    respond_to do |format|
      format.json do
        render json: @release.to_json
      end
    end
  end

  def search
    find_tracks
    respond_to do |format|
      format.json do
        render json: @tracks.to_json
      end
    end
  end

  private

  def get_releases
    @releases = Release.order(:name).map{|release| { release: { id: release.id, name: release.name } } }
  end

  def get_release
    @release = Release.find(params[:id]).tracks.map{|track| { track: { id: track.id, name: track.title } } }
  end

  def find_tracks
    @search = Track.includes(:release).search do
      fulltext params[:q]
      paginate :page => params[:page], :per_page => params[:per_page]
    end
    @tracks = @search.hits.map do |hit|
      [hit.score, hit.result.id, hit.result.artist, hit.result.title, hit.result.bitrate]
    end
  end

end