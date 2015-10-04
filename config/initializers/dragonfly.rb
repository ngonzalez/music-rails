require 'dragonfly'

class LameEncoderProcessor
  def self.call(content)
    content.shell_update ext: 'mp3', escape: false do |old_path, new_path|
      "`which lame` -V0 #{Shellwords.escape(old_path)} #{new_path}"  # The command sent to the command line
    end
  end
end

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  processor :lame_encoder, LameEncoderProcessor

  secret "8b00701357a0f7d45c5a5bedc64ba3a7db423a86a1b6ff2d1d752210f3212941"

  url_format "/media/:job/:name"

  datastore :file,
    root_path: Rails.root.join('public/system/dragonfly', 'development'),
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
