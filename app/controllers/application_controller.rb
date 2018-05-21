class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  private
  def redis_db
    @redis_db ||= Redis.new host: '127.0.0.1', port: 6379, db: 0
  end
end