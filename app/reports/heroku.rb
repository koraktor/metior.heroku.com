# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'metior'

class Metior::Report

  # @author Sebastian Staudt
  class Heroku < self

    @@assets = []

    @@name = :heroku

    @@views = [ :index ]

    def init
      @commits.modifications if repository.supports? :line_stats
    end
    
    def self.path
      File.join File.dirname(__FILE__), name
    end

  end

end
