require File.expand_path('../boot', __FILE__)

require 'action_controller/railtie'
require 'sprockets/railtie'

Bundler.require :default, :assets, Rails.env

module Metior

  class Application < Rails::Application

    config.assets.enabled = true
    config.assets.version = '1.0'

    config.encoding = "utf-8"

    config.mongoid.preload_models = false

    def self.tmp_path
      @@tmp_path ||= File.join Rails.root, 'tmp'
    end

  end

end
