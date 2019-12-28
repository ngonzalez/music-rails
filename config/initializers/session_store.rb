# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :redis_store,
  servers: ["redis://127.0.0.1:6379/0/session"],
  expire_after: 90.minutes,
  key: "_#{Rails.application.class.parent_name.downcase}_session"
