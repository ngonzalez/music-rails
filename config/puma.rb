# config/puma.rb

#
# bundle exec puma -p 9292 --config config/puma.rb

threads 8,32
workers 5
worker_timeout 15
stdout_redirect '/tmp/puma.stdout.log', '/tmp/puma.stderr.log', true
preload_app!

# root = "#{Dir.getwd}" ; base_directory = "#{root}/tmp/puma"
# FileUtils.mkdir_p(base_directory) if !File.directory? base_directory

# bind "unix://#{base_directory}/socket"
# pidfile "#{base_directory}/pid"
# state_path "#{base_directory}/state"
# rackup "#{root}/config.ru"

# activate_control_app
