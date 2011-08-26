require ::File.expand_path('../config/environment',  __FILE__)

use Rack::Cache,
  :verbose     => true,
  :metastore   => "memcached://#{ENV['MEMCACHE_SERVERS']}",
  :entitystore => "memcached://#{ENV['MEMCACHE_SERVERS']}"

run Metior::Application
