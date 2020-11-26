# BASE_PATH
if ENV['BASE_PATH'].present?
  BASE_PATH = ENV['BASE_PATH']
else
  raise "Missing ENV BASE_PATH"
end

# HLS_FOLDER
if ENV['HLS_FOLDER'].present?
  HLS_FOLDER = ENV['HLS_FOLDER']
else
  raise "Missing ENV HLS_FOLDER"
end

# HOST_NAME
if ENV['HOST_NAME'].present?
  HOST_NAME = ENV['HOST_NAME']
else
  raise "Missing ENV HOST_NAME"
end

# POSTGRESQL_HOST
if ENV['POSTGRESQL_HOST'].present?
  POSTGRESQL_HOST = ENV['POSTGRESQL_HOST']
else
  raise "Missing ENV POSTGRESQL_HOST"
end

# POSTGRESQL_PORT
if ENV['POSTGRESQL_PORT'].present?
  POSTGRESQL_PORT = ENV['POSTGRESQL_PORT'].to_i
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
if ENV['POSTGRESQL_PASSWORD'].present? || ENV['POSTGRESQL_PASSWORD'].blank? # optional
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
  REDIS_PORT = ENV['REDIS_PORT'].to_i
else
  raise "Missing ENV REDIS_PORT"
end

# REDIS_DB
if ENV['REDIS_DB'].present?
  REDIS_DB = ENV['REDIS_DB'].to_i
else
  raise "Missing ENV REDIS_DB"
end

# SUNSPOT_SOLR_HOSTNAME
if ENV['SUNSPOT_SOLR_HOSTNAME'].present?
  SUNSPOT_SOLR_HOSTNAME = ENV['SUNSPOT_SOLR_HOSTNAME']
else
  raise "Missing ENV SUNSPOT_SOLR_HOSTNAME"
end

# SUNSPOT_SOLR_PORT
if ENV['SUNSPOT_SOLR_PORT'].present?
  SUNSPOT_SOLR_PORT = ENV['SUNSPOT_SOLR_PORT'].to_i
else
  raise "Missing ENV SUNSPOT_SOLR_PORT"
end

# SUNSPOT_SOLR_PATH
if ENV['SUNSPOT_SOLR_PATH'].present?
  SUNSPOT_SOLR_PATH = ENV['SUNSPOT_SOLR_PATH']
else
  raise "Missing ENV SUNSPOT_SOLR_PATH"
end

ALLOWED_AUDIO_FORMATS   = YAML.load_file File.expand_path('../config/yaml/allowed_audio_formats.yaml', __dir__)
ALLOWED_IMAGE_FORMATS   = YAML.load_file File.expand_path('../config/yaml/allowed_image_formats.yaml', __dir__)
ALLOWED_SOURCES         = YAML.load_file File.expand_path('../config/yaml/allowed_sources.yaml', __dir__)
FA_CSS                  = YAML.load_file File.expand_path('../config/yaml/fa_css.yaml', __dir__)
FOLDERS                 = YAML.load_file File.expand_path('../config/yaml/folders.yaml', __dir__)
FOLDERS_WITH_SUBFOLDERS = YAML.load_file File.expand_path('../config/yaml/folders_with_subfolders.yaml', __dir__)
EXCEPT_NAMES            = YAML.load_file File.expand_path('../config/yaml/except_names.yaml', __dir__)
