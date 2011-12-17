class ApplicationController < ActionController::Base
  protect_from_forgery

  def not_found
    flash[:error] = 'The page you requested does not exist.'
    redirect_to '/'
  end

  def render(*args)
    @current_view = args.first
    if @current_view.is_a? Hash
      @current_view = @current_view[:template] || action_name
    end
    @current_view = @current_view.to_sym

    super
  end

end
