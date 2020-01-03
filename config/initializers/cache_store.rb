# Be sure to restart your server when you modify this file.

Rails.application.config.cache_store = :redis_store, {
  cluster: %w["redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/#{ENV['REDIS_DB']}"],
  expires_in: 90.minutes,
  namespace: "cache"
}
