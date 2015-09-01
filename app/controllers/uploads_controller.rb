class UploadsController < ApplicationController

  def new ; end

  def create
    upload = Upload.create! file: params[:Filedata]
    render json: upload.to_json, status: 200
  end

end