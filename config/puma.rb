# config/puma.rb

#
# bundle exec puma -p 9292 --config puma.rb

threads 8,32
workers 3
worker_timeout 15
preload_app!

root = "#{Dir.getwd}"

bind "unix://#{root}/tmp/puma/socket"
pidfile "#{root}/tmp/puma/pid"
state_path "#{root}/tmp/puma/state"
rackup "#{root}/config.ru"

activate_control_app
