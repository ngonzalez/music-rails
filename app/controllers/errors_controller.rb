class ErrorsController < ApplicationController
  def raise_not_found!
    render file: "#{Rails.root}/public/404.html", status: 400, layout: false
  end
end