require 'octokit'

require File.join(Rails.root, 'app', 'reports', 'heroku')

class StatsController < ApplicationController

  rescue_from Octokit::Forbidden do
    flash.now[:error] = "The limit for GitHub API calls has been " <<
                        "exceeded.<br />Please try again later."
    render :index, :status => :forbidden
  end

  rescue_from Octokit::NotFound do
    flash.now[:error] = "#{@github_project} does not exist."
    render :index, :status => :not_found
  end

  rescue_from Octokit::Unauthorized do
    flash.now[:error] = "#{@github_project} is private.<br />" <<
                        "Sorry, private repositories are not supported yet."
    render :index, :status => :unauthorized
  end

  def basic_stats
    generate_report_and_show_view :basic_stats
  end

  def calendar
    generate_report_and_show_view :calendar
  end

  def index
    response.headers['Cache-Control'] = "public, max-age=180"

    render :layout => 'application'
  end

  private

  def find_or_create_project
    user = User.find_or_initialize_by :id => @user.downcase
    user.name = @user unless user.persisted?

    project_id = @github_project.downcase.sub '/', '-fwdslsh-'
    project = user.projects.find_or_initialize_by :id => project_id
    unless project.persisted?
      project.path = @github_project
      github_info = Octokit.repository project.path
      project.name = github_info.name
      user.name = github_info.owner
      project.path = "#{user.name}/#{project.name}"
      project.description = github_info.description
    end

    user.save!
    project.save!
    project
  end

  def generate_report_and_show_view(view)
    @user, @project = params[:user], params[:project]
    @github_project = "#{@user}/#{@project}"

    project = find_or_create_project

    if @project != project.name || @user != project.user.name
      redirect_to "/#{project.path}"
      return
    end

    cloned_now = false
    unless project.cloned?
      unless project.clone
        flash.now[:error] = "#{@github_project} could not bet fetched from GitHub."
        not_found
        return
      end
      cloned_now = true
    end

    @report = project.reports.find_or_initialize_by :branch => project.default_branch

    if @report.fresh?
      cache_time = 3600 - @report.age
    else
      cache_time = 3600

      project.pull unless cloned_now

      unless project.generate_report
        flash.now[:error] = "#{@github_project} has no commits in the " <<
                            "\"#{project.default_branch}\" branch."
        not_found
        return
      end
    end

    response.headers['Cache-Control'] = "public, max-age=#{cache_time}"
    render :text => @report.output[view.to_s], :content_type => 'text/html',
           :layout => true
  end

  def not_found
    render :index, :status => :not_found
  end

end
