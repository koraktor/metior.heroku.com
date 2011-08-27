require 'grit'

require File.join(Rails.root, 'app', 'reports', 'heroku')

class StatsController < ApplicationController

  def basic_stats
    return unless generate_report
    render :file => File.join(report_path, 'basic_stats.html')
  end

  def calendar
    return unless generate_report
    render :file => File.join(report_path, 'calendar.html')
  end

  private

  def generate_report
    @user, @project = params[:user], params[:project]
    @github_project = "#{@user}/#{@project}"

    if File.exist? report_path
      last_update = File.mtime File.join(report_path, 'basic_stats.html')
      if last_update > Time.now - 3600
        cache_time = 3600 - (Time.now - last_update).to_i
        response.headers['Cache-Control'] = "public, max-age=#{cache_time}"
        return true
      end
    end

    repo_path = "#{tmp_path}/repositories/#{@github_project}.git"
    if File.exist? repo_path
      `git --git-dir #{repo_path} remote update`
      logger.warn "#{@github_project} could not be updated." unless $?.success?
    else
      `git clone --mirror git://github.com/#{@github_project}.git #{repo_path}`
      unless $?.success?
        flash.now[:error] = "#{@github_project} could not bet fetched from GitHub."
        render :index, :status => :not_found
        return false
      end
    end

    repo = Metior::Git::Repository.new repo_path
    current_branch = repo.instance_variable_get(:@grit_repo).head.name
    if repo.commits(current_branch).empty?
      flash.now[:error] = "#{@github_project} has no commits in the " <<
                          "\"#{current_branch}\" branch."
      render :index, :status => :not_found
      return false
    end

    Metior::Report::Heroku.new(repo, current_branch).generate report_path

    response.headers['Cache-Control'] = 'public, max-age=3600'
    true
  end

  def report_path
    @report_path ||= "#{tmp_path}/reports/#{@github_project}"
  end

  def tmp_path
    @tmp_path ||= File.join Rails.root, 'tmp'
  end

end
