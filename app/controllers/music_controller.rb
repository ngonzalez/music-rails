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
        render json: @tracks.to_json
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
    @releases = Release.order "LOWER(#{Release.table_name}.name)"
  end

  def get_release
    release = Release.find params[:id]
    @tracks = { release.id => { name: release.name, tracks: release.tracks.order(:name) } }
  end

  def find_tracks
    @tracks = Track.search(include: [:release]) { fulltext params[:q] ; paginate :page => params[:page], :per_page => params[:per_page] }.hits.each_with_object({}) do |hit, hash|
      hash[hit.result.release_id] = { name: hit.result.release.name, tracks: [] } if !hash.has_key?(hit.result.release_id)
      hash[hit.result.release_id][:tracks] << hit.result.attributes.merge(score: hit.score)
    end
  end

end