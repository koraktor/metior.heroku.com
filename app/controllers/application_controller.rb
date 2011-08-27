class ApplicationController < ActionController::Base
  protect_from_forgery

  def not_found
    flash[:error] = 'The page you requested does not exist.'
    redirect_to '/'
  end

end
