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
    label_name = LABELS.detect{|name| name.downcase == params[:q].downcase } if LABELS.map(&:downcase).include? params[:q].downcase
    year = params[:q].scan(/\b\d{4}\b/)[0].to_i
    hash = {}
    if label_name
      search = Release.search {
        paginate :page => params[:page], :per_page => params[:rows]
        with(:label_name, label_name)
      }
      search.hits.each{|hit|
        begin
          next if hash.has_key? hit.result.id
          hash[hit.result.id] = hit.result.decorate.search_infos
        rescue
          next
        end
      }
      order = :year
    elsif year > 0
      search = Release.search {
        paginate :page => params[:page], :per_page => params[:rows]
        with(:year, year)
      }
      search.hits.each{|hit|
        begin
          next if hash.has_key? hit.result.id
          hash[hit.result.id] = hit.result.decorate.search_infos
        rescue
          next
        end
      }
      order = :name
    elsif !params[:q].blank?
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
      order = :year
    end
    return hash.sort_by{|k, v| v[order] || 0 }.reverse
  end

end