# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'heroku'

class ReportJob

  @@heroku = Heroku::Client.new ENV['HEROKU_LOGIN'], ENV['HEROKU_PASSWORD']

  def self.after_enqueue_scale_up(*args)
    if ENV.key? 'HEROKU_APP'
      ReportJob.workers = 1 if ReportJob.workers == 0
    end
  end

  def self.after_perform_scale_down(*args)
    if ENV.key? 'HEROKU_APP'
      ReportJob.workers = 0 if ReportJob.job_count == 0
    end
  end

  def self.job_count
    Resque.info[:pending].to_i
  end

  def self.perform(github_project, branch)
    $stdout.puts "--- Started working on #{github_project}@#{branch}..."

    project = Project.where(:path => github_project).first

    if project.cloned?
      unless project.pull
        $stderr.puts "---   Failed to pull changes from #{github_project}."
        return
      end
    else
      unless project.clone
        $stderr.puts "---   Failed to clone #{github_project}."
        raise "Failed to clone #{github_project}."
      end
    end

    branch = project.default_branch if branch.nil?
    report = project.reports.find_or_initialize_by :branch => branch
    report.generate

    $stdout.puts "--- Done working on #{github_project}@#{branch}."
  end

  def self.queue
    :report
  end

  def self.workers
    @@heroku.ps(ENV['HEROKU_APP']).count { |p| p['process'] =~ /^worker\./ }
  end

  def self.workers=(count)
    @@heroku.ps_scale ENV['HEROKU_APP'], :type => 'worker', :qty => count
  end

end
