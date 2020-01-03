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

ALLOWED_AUDIO_FORMATS   = YAML.load_file File.expand_path('../config/yaml/allowed_audio_formats.yaml', __dir__)
ALLOWED_IMAGE_FORMATS   = YAML.load_file File.expand_path('../config/yaml/allowed_image_formats.yaml', __dir__)
ALLOWED_SOURCES         = YAML.load_file File.expand_path('../config/yaml/allowed_sources.yaml', __dir__)
FOLDERS                 = YAML.load_file File.expand_path('../config/yaml/folders.yaml', __dir__)
FOLDERS_WITH_SUBFOLDERS = YAML.load_file File.expand_path('../config/yaml/folders_with_subfolders.yaml', __dir__)
EXCEPT_RLS              = YAML.load_file File.expand_path('../config/yaml/except_rls.yaml', __dir__)
EXCEPT_NAMES            = YAML.load_file File.expand_path('../config/yaml/except_names.yaml', __dir__)
