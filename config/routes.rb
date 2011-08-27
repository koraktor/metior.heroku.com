Metior::Application.routes.draw do

  project_constraints = { :project => /[-_.A-z0-9]+/, :user => /[-_.A-z0-9]+/ }

  match '/' => 'stats#index'

  match '/stats' => redirect { |params, req| "/#{req[:user]}/#{req[:project]}" }

  match '/:user/:project' => 'stats#basic_stats',
    :constraints => project_constraints

  match '/:user/:project/calendar' => 'stats#calendar',
    :constraints => project_constraints

  match '*url', :to => 'application#not_found'

end
