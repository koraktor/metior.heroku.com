# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

class Metior::Report::Heroku

  # @author Sebastian Staudt
  class BasicStats < View

    def init
      @activity = @report.commits.activity
    end

    def authors
      @report.commits.authors.most_significant(5).values
    end

    def commit_count
      @report.commits.size
    end

    def commits_per_active_day
      (@activity[:commits_per_active_day] * 100).round / 100.0 rescue 0
    end

    def committers
      @report.commits.authors.top(5).values
    end

    def committer_commit_count
      self[:authored_commits].size
    end

    def initial_commit_date
      @activity[:first_commit_date]
    end

    def last_commit_date
      @activity[:last_commit_date]
    end

    def most_active_day
      @activity[:most_active_day].strftime '%m/%d/%Y' rescue ''
    end

    def most_significant_commits
      @report.commits.most_significant(5).values
    end

    def range
      @report.range
    end

    def reset_count
      super
      nil
    end

  end

end
