require 'dragonfly'

# Configure
Dragonfly.app.configure do
  # plugin :imagemagick

  secret "8b00701357a0f7d45c5a5bedc64ba3a7db423a86a1b6ff2d1d752210f3212941"

  url_format "/media/:job/:name"

  datastore :file,
    root_path: Rails.root.join('public/system/dragonfly', Rails.env),
    server_root: Rails.root.join('public')
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
