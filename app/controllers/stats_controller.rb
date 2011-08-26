require 'grit'

require File.join(Rails.root, 'app', 'reports', 'heroku')

class StatsController < ApplicationController

  def report
    @user, @project = params[:user], params[:project]

    response.headers['Cache-Control'] = 'public, max-age=3600'

    github_project = "#{@user}/#{@project}"
    @title = github_project

    repo_path = "#{tmp_path}/repositories/#{github_project}.git"
    if File.exist? repo_path
      `git --git-dir #{repo_path} remote update`
      logger.warn "#{github_project} could not be updated." unless $?.success?
    else
      `git clone --mirror git://github.com/#{github_project}.git #{repo_path}`
      unless $?.success?
        flash.now[:error] = "#{github_project} could not bet fetched from GitHub."
        render :index, :status => :not_found
        return
      end
    end
    repo = Metior::Git::Repository.new repo_path
    if repo.commits.empty?
      flash.now[:error] = "#{github_project} has no commits in the \"master\" " <<
                      "branch.<br />Support for other branches will be " <<
                      "added soon."
      render :index, :status => :not_found
      return
    end

    report_path = "#{tmp_path}/reports/#{github_project}"
    Metior::Report::Heroku.new(repo).generate report_path

    render :file => File.join(report_path, 'index.html')
  end

  def tmp_path
    @tmp_path ||= File.join Rails.root, 'tmp'
  end

end
