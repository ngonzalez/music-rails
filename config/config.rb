require 'dotenv/load'

# APP_SERVER_HOST
if ENV['APP_SERVER_HOST'].present?
  APP_SERVER_HOST = ENV['APP_SERVER_HOST']
else
  raise "Missing ENV APP_SERVER_HOST"
end

# APP_SERVER_PORT
if ENV['APP_SERVER_PORT'].present?
  APP_SERVER_PORT = ENV['APP_SERVER_PORT']
else
  raise "Missing ENV APP_SERVER_PORT"
end

# APP_SERVER_PATH
if ENV['APP_SERVER_PATH'].present?
  APP_SERVER_PATH = ENV['APP_SERVER_PATH']
else
  raise "Missing ENV APP_SERVER_PATH"
end

# BACKUP_SERVER_HOST
if ENV['BACKUP_SERVER_HOST'].present?
  BACKUP_SERVER_HOST = ENV['BACKUP_SERVER_HOST']
else
  raise "Missing ENV BACKUP_SERVER_HOST"
end

# BACKUP_SERVER_PORT
if ENV['BACKUP_SERVER_PORT'].present?
  BACKUP_SERVER_PORT = ENV['BACKUP_SERVER_PORT']
else
  raise "Missing ENV BACKUP_SERVER_PORT"
end

# BACKUP_SERVER_PATH
if ENV['BACKUP_SERVER_PATH'].present?
  BACKUP_SERVER_PATH = ENV['BACKUP_SERVER_PATH']
else
  raise "Missing ENV BACKUP_SERVER_PATH"
end

# POSTGRESQL_HOST
if ENV['POSTGRESQL_HOST'].present?
  POSTGRESQL_HOST = ENV['POSTGRESQL_HOST']
else
  raise "Missing ENV POSTGRESQL_HOST"
end

# POSTGRESQL_PORT
if ENV['POSTGRESQL_PORT'].present?
  POSTGRESQL_PORT = ENV['POSTGRESQL_PORT']
else
  raise "Missing ENV POSTGRESQL_PORT"
end

# POSTGRESQL_DB
if ENV['POSTGRESQL_DB'].present?
  POSTGRESQL_DB = ENV['POSTGRESQL_DB']
else
  raise "Missing ENV POSTGRESQL_DB"
end

# POSTGRESQL_USERNAME
if ENV['POSTGRESQL_USERNAME'].present?
  POSTGRESQL_USERNAME = ENV['POSTGRESQL_USERNAME']
else
  raise "Missing ENV POSTGRESQL_USERNAME"
end

# POSTGRESQL_PASSWORD
if ENV['POSTGRESQL_PASSWORD'].present?
  POSTGRESQL_PASSWORD = ENV['POSTGRESQL_PASSWORD']
else
  raise "Missing ENV POSTGRESQL_PASSWORD"
end

# REDIS_HOST
if ENV['REDIS_HOST'].present?
  REDIS_HOST = ENV['REDIS_HOST']
else
  raise "Missing ENV REDIS_HOST"
end

# REDIS_PORT
if ENV['REDIS_PORT'].present?
  REDIS_PORT = ENV['REDIS_PORT']
else
  raise "Missing ENV REDIS_PORT"
end

# REDIS_DB
if ENV['REDIS_DB'].present?
  REDIS_DB = ENV['REDIS_DB']
else
  raise "Missing ENV REDIS_DB"
end

# SOLR_HOST
if ENV['SOLR_HOST'].present?
  SOLR_HOST = ENV['SOLR_HOST']
else
  raise "Missing ENV SOLR_HOST"
end

# SOLR_PORT
if ENV['SOLR_PORT'].present?
  SOLR_PORT = ENV['SOLR_PORT']
else
  raise "Missing ENV SOLR_PORT"
end

# SOLR_PATH
if ENV['SOLR_PATH'].present?
  SOLR_PATH = ENV['SOLR_PATH']
else
  raise "Missing ENV SOLR_PATH"
end

ALLOWED_AUDIO_FORMATS = YAML.load_file File.expand_path('../config/yaml/allowed_audio_formats.yaml', __dir__)
ALLOWED_IMAGE_FORMATS = YAML.load_file File.expand_path('../config/yaml/allowed_image_formats.yaml', __dir__)
