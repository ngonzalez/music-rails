class MusicController < ApplicationController

  def index
    respond_to do |format|
      format.html do
        render nothing: true
      end
      format.json do
        render json: {}.to_json, layout: false, status: 200
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
        render json: @releases.to_json, layout: false, status: 200
      end
    end
  end

  private

  def set_release
    @release = Release.find(params[:id]).decorate
  end

  def set_tracks
    @tracks = @release.tracks.decorate.sort { |a, b| a.number <=> b.number }
  end

  def search_releases
    return [] if params[:q].blank? && params[:subfolder].blank?
    subfolder = params[:subfolder]
    year = params[:q].scan(/\b\d{4}\b/)[0].to_i if params[:q] && params[:q].length == 4
    params[:rows] ||= 100000
    params[:page] ||= 1
    hash = {}
    if subfolder
      search = Release.search {
        paginate :page => params[:page], :per_page => params[:rows]
        with(:subfolder, subfolder)
      }
      search.hits.each { |hit| hash[hit.result.id] = hit.result.decorate.search_infos }
      @releases = hash.sort_by { |k, v| v[:year] || 0 }.reverse
    elsif year && year > 0
      search = Release.search {
        paginate :page => params[:page], :per_page => params[:rows]
        with(:year, year)
      }
      search.hits.each { |hit| hash[hit.result.id] = hit.result.decorate.search_infos }
      @releases = hash.sort_by { |k, v| v[:formatted_name] || 0 }
    elsif !params[:q].blank?
      search = Track.search(include: [:release]) {
        fulltext params[:q]
        paginate :page => params[:page], :per_page => params[:rows]
      }
      search.hits.each { |hit| hash[hit.result.release_id] = hit.result.release.decorate.search_infos }
      @releases = hash.sort_by { |k, v| v[:year] || 0 }.reverse
    end
  end
end