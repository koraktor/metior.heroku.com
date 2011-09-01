require 'octokit'

require File.join(Rails.root, 'app', 'reports', 'heroku')

class StatsController < ApplicationController

  rescue_from Octokit::Forbidden do
    flash.now[:error] = "The limit for GitHub API calls has been " <<
                        "exceeded.<br />Please try again later."
    render :index, :layout => 'application', :status => :forbidden
  end

  rescue_from Octokit::NotFound do
    flash.now[:error] = "#{@github_project} does not exist."
    render :index, :layout => 'application', :status => :not_found
  end

  rescue_from Octokit::Unauthorized do
    flash.now[:error] = "#{@github_project} is private.<br />" <<
                        "Sorry, private repositories are not supported yet."
    render :index, :layout => 'application', :status => :unauthorized
  end

  def basic_stats
    generate_report_and_show_view :basic_stats
  end

  def calendar
    generate_report_and_show_view :calendar, 'stats/calendar'
  end

  def index
    response.headers['Cache-Control'] = "public, max-age=180"

    render :layout => 'application'
  end

  private

  def find_or_create_project
    user = User.find_or_initialize_by :name => @user.downcase
    user.name = @user unless user.persisted?

    project = user.projects.find_or_initialize_by :name => @project
    unless project.persisted?
      github_info = Octokit.repository "#{user.name}/#{project.name}"
      project.name = github_info.name
      user.name = github_info.owner
      project.description = github_info.description
      project.path = "#{user.name}/#{project.name}"
    end

    user.save!
    project.save!
    project
  end

  def generate_report_and_show_view(view, layout = nil)
    @user, @project = params[:user], params[:project]

    project = find_or_create_project
    @github_project = project.path

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

    layout = true if layout.nil?

    response.headers['Cache-Control'] = "public, max-age=#{cache_time}"
    render :text => @report.output[view.to_s], :content_type => 'text/html',
           :layout => layout
  end

  def not_found
    render :index, :status => :not_found
  end

end
