class MusicController < ApplicationController

  def index
    @releases = find_releases
    respond_to do |format|
      format.json do
        render json: @releases.to_json
      end
    end
  end

  def show
    @tracks = find_release
    @images = find_images
    @nfo = find_nfo
    respond_to do |format|
      format.html
      format.json do
        render json: @tracks.to_json
      end
    end
  end

  def search
    @t1 = Time.now
    @releases = search_releases
    respond_to do |format|
      format.html
      format.json do
        render json: @releases.to_json
      end
    end
  end

  private

  def find_releases
    Release.order("LOWER(#{Release.table_name}.name)").map do |release|
      {
        id: release.id,
        name: release.name,
        url: music_url(release.id, format: :json)
      }
    end
  end

  def find_release
    Release.find(params[:id]).tracks.decorate.sort{|a, b| a.number <=> b.number }
  end

  def find_images
    Image.where(release_id: params[:id], file_type: nil).decorate
  end

  def find_nfo
    Image.where(release_id: params[:id], file_type: NFO_TYPE)
  end

  def search_releases
    return [] if params[:q].blank?
    hash = {}
    if params[:q] =~ /label:/
      search_terms = params[:q].gsub("label:", "").downcase
      Release.where("LOWER(UNACCENT(#{Release.table_name}.label_name)) = ?", search_terms).decorate.each{|release|
        hash[release.id] = release.search_infos
      }
    else
      search = Track.search(include: [:release]) {
        fulltext params[:q]
        paginate :page => params[:page], :per_page => params[:rows]
      }
      search.hits.each{|hit|
        begin
          next if hash.has_key? hit.result.release_id
          hash[hit.result.release_id] = hit.result.release.decorate.search_infos
        rescue
          next
        end
      }
    end
    return hash.sort_by{|k, v| v[:year] || 0 }.reverse
  end

end