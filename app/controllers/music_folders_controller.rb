class MusicFoldersController < ApplicationController
  require Rails.root.join "lib/helpers/search_helpers"
  include SearchHelpers

  before_action :session_store
  before_action :session_load

  attr_accessor :search_params
  helper_method :search_params

  before_action :set_time, only: [:index]
  before_action :search_music_folders, only: [:index]

  before_action :set_music_folder, only: [:show]
  before_action :set_audio_files, only: [:show]

  def index
    respond_to do |format|
      format.html
      format.json do
        render json: @music_folders.to_json,
          layout: false
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json do
        render json: @audio_files.to_json,
          layout: false
      end
    end
  end

  private

  def set_folder
    @music_folder = MusicFolder.friendly.find(params[:id]).decorate
  end

  def set_audio_files
    @audio_files = @music_folder.audio_files.decorate.sort { |a, b| a.number <=> b.number }.map &:attributes
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

  def search_music_folders
    @music_folders = search_params.values.all?(&:blank?) ? [] : search_db(parse_search_params(search_params))
  end
end
