APP_SERVER_TMP_PATH = "/tmp/" + APP_SERVER_PATH

unless File.exists? APP_SERVER_TMP_PATH
  FileUtils.mkdir APP_SERVER_TMP_PATH
end
