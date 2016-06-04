class UploadsController < ApplicationController

  def new ; end

  def create
    upload = Upload.create! file: params[:Filedata]
    upload_attributes = upload.attributes.deep_symbolize_keys.slice :file_uid, :file_name, :created_at
    upload_attributes.merge! media: "http://" + HOST_NAME + upload.file.url
    render json: upload_attributes.to_json, status: 200
  end

end