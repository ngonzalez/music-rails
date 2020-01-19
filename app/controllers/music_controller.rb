class MusicController < ApplicationController
  require Rails.root.join "lib/helpers/search_helpers"
  include SearchHelpers

  before_action :session_store
  before_action :session_load

  attr_accessor :search_params
  helper_method :search_params

  before_action :set_time, only: [:index]
  before_action :search_releases, only: [:index]

  before_action :set_release, only: [:show]
  before_action :set_tracks, only: [:show]

  def index
    respond_to do |format|
      format.html
      format.json do
        render json: @releases.to_json,
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

  private

  def set_release
    @release = Release.friendly.find(params[:id]).decorate
  end

  def set_tracks
    @tracks = @release.tracks.decorate.sort { |a, b| a.number <=> b.number }.map &:attributes
  end

  def set_time
    @t1 = Time.now
  end

  def permitted_params
    params.permit :format, :q, :folder, :subfolder
  end

  def session_store
    session[:search_params] = permitted_params.to_hash.compact.to_json if permitted_params.to_hash.compact.any?
  end

  def session_load
    @search_params = session[:search_params] ? JSON.parse(session[:search_params], symbolize_names: true) : {}
  end

  def search_releases
    @releases = search_params.values.all?(&:blank?) ? [] : search_db(parse_search_params(search_params))
  end
end
