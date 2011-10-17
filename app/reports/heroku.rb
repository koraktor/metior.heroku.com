# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'metior'

class Metior::Report

  # @author Sebastian Staudt
  class Heroku < Default

    assets []

    views [ :basic_stats, :calendar ]

    def self.path
      File.join File.dirname(__FILE__), name
    end

  end

end
