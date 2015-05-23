class MusicController < ApplicationController

  def index
    @releases = get_releases
    respond_to do |format|
      format.html
      format.json do
        render json: @releases.to_json
      end
    end
  end

  def show
    @release = get_release
    respond_to do |format|
      format.html
      format.json do
        render json: @release.to_json
      end
    end
  end

  def search
    @tracks = find_tracks
    respond_to do |format|
      format.html
      format.json do
        render json: @tracks.to_json
      end
    end
  end

  private

  def get_releases
    Release.order("LOWER(#{Release.table_name}.name)").map do |release|
      {
        id: release.id,
        name: release.name,
        url: music_url(release.id, format: :json)
      }
    end
  end

  def get_release
    Release.find(params[:id]).tracks.map do |track|
      track.attributes.merge(path: track.file_url)
    end
  end

  def find_tracks
    search = Track.search(include: [:release]) {
      fulltext params[:q]
      paginate :page => params[:page], :per_page => params[:rows]
    }
    search.hits.each_with_object({}) do |hit, hash|
      hash[hit.result.release_id] = {
        name: hit.result.release.name,
        url: music_url(hit.result.release, format: params.slice("format"))
      }
    end
  end

end