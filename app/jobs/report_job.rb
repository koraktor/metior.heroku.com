# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

class ReportJob

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

end
