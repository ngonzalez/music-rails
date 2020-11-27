require 'dragonfly'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret "8b00701357a0f7d45c5a5bedc64ba3a7db423a86a1b6ff2d1d752210f3212941"

  url_format "/media/:job/:id"

  datastore :google,
    project: 'hebe-001',
    bucket: 'hebe-001.appspot.com',
    keyfile: 'config/gcp_key.json'
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
