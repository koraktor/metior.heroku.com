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

  rescue_from SocketError do
    flash.now[:error] = "There was a problem communicating with GitHub." <<
                        "<br />Please try again in a few minutes."
    @user, @project = nil
    render :index, :layout => 'application', :status => :internal_error
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
    user = User.find_or_initialize_by :name => @user
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

  def generate_report_and_show_view(view, layout = true)
    @user, @project = params[:user], params[:project]
    @github_project = "#{@user}/#{@project}"

    project = find_or_create_project
    @github_project = project.path

    if @project != project.name || @user != project.user.name
      redirect_to "/#{project.path}"
      return
    end

    @report = project.reports.find_or_initialize_by :branch => project.default_branch
    last_error = @report.last_error

    output = @report.output[view.to_s] if @report.available?

    if @report.fresh?
      cache_time = 3600 - @report.age
    else
      @report.queue! if last_error.nil? && !@report.queued?

      cache_time = 5

      if @report.available?
        flash.now[:notice] = "The report for #{@github_project} will be re-generated soon."
      else
        flash.now[:notice] = "The report for #{@github_project} will be generated soon."
        render :unavailable, :layout => 'application'
      end
    end

    unless last_error.nil?
      flash.now[:error]  = last_error
      flash.now[:notice] = nil
    end

    if response_body.nil?
      response.headers['Cache-Control'] = "public, max-age=#{cache_time}"
      render :text => output, :content_type => 'text/html',
             :layout => layout
    end
  end

  def not_found
    render :index, :status => :not_found
  end

end
