require ::File.expand_path('../config/environment',  __FILE__)

if ENV.key? 'MEMCACHE_SERVERS'
  use Rack::Cache,
    :verbose     => true,
    :metastore   => "memcached://#{ENV['MEMCACHE_SERVERS']}",
    :entitystore => "memcached://#{ENV['MEMCACHE_SERVERS']}"
end

run Metior::Application
