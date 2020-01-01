# Be sure to restart your server when you modify this file.

Rails.application.config.action_dispatch.rack_cache = {
  metastore: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/#{ENV['REDIS_DB']}/metastore",
  entitystore: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/#{ENV['REDIS_DB']}/entitystore"
}
