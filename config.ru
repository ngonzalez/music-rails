# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

require 'rack/cache'

use Rack::Cache,
  :verbose     => true,
  :metastore   => 'file:/tmp/rack-cache/meta',
  :entitystore => 'file:/tmp/rack-cache/body'

run Rails.application
