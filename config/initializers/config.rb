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

ALLOWED_AUDIO_FORMATS   = YAML.load_file Rails.root.join('config/yaml/allowed_audio_formats.yaml')
ALLOWED_IMAGE_FORMATS   = YAML.load_file Rails.root.join('config/yaml/allowed_image_formats.yaml')
ALLOWED_SOURCES         = YAML.load_file Rails.root.join('config/yaml/allowed_sources.yaml')
FOLDERS                 = YAML.load_file Rails.root.join('config/yaml/folders.yaml')
FOLDERS_WITH_SUBFOLDERS = YAML.load_file Rails.root.join('config/yaml/folders_with_subfolders.yaml')
EXCEPT_RLS              = YAML.load_file Rails.root.join('config/yaml/except_rls.yaml')
EXCEPT_NAMES            = YAML.load_file Rails.root.join('config/yaml/except_names.yaml')
