class MusicController < ApplicationController

  def index
    @releases = get_releases
    respond_to do |format|
      format.json do
        render json: @releases.to_json
      end
    end
  end

  def show
    @tracks = get_release
    @images = get_images
    @nfo = get_nfo
    respond_to do |format|
      format.html
      format.json do
        render json: @tracks.to_json
      end
    end
  end

  def search
    @t1 = Time.now
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
    Release.find(params[:id]).tracks.decorate.sort{|a, b| a.number <=> b.number }
  end

  def get_images
    Image.where(release_id: params[:id], file_type: nil).decorate
  end

  def get_nfo
    Image.where(release_id: params[:id], file_type: NFO_TYPE)
  end

  def find_tracks
    return [] if params[:q].blank?
    search = Track.search(include: [:release]) {
      fulltext params[:q]
      paginate :page => params[:page], :per_page => params[:rows]
    }
    hash = {}
    search.hits.each do |hit|
      track = hit.result
      release = hit.result.release
      begin
        next if hash.has_key? track.release_id
        hash[track.release_id] = {
          name: release.formatted_name,
          folder: release.folder,
          format_name: track.format_name,
          url: music_url(release, format: params.slice("format")),
          year: track.year.to_i
        }
      rescue
        next
      end
    end
    return hash.sort_by{|k, v| v[:year] || 0 }.reverse
  end

end