class MusicController < ApplicationController
  require Rails.root.join "lib/helpers/search_helpers"
  include SearchHelpers

  before_action :set_release, only: [:show]
  before_action :set_tracks, only: [:show]

  before_action :set_time, only: [:search]
  before_action :search_releases, only: [:search]

  def index
    respond_to do |format|
      format.html do
        render nothing: true
      end
      format.json do
        render json: {}.to_json,
          layout: false
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json do
        render json: @tracks.to_json,
          layout: false
      end
    end
  end

  def search
    respond_to do |format|
      format.html
      format.json do
        render json: @releases.map(&:marshal_dump).to_json,
          layout: false
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

  def set_time
    @t1 = Time.now
  end

  def search_params
    @search_params ||= get_search_params params.permit(:q, :folder, :subfolder)
  end

  def search_releases
    @releases = search_params.values.all?(&:blank?) ? [] : search_db(search_params)
  end
end
