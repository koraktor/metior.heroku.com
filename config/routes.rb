Metior::Application.routes.draw do

  match '/' => 'stats#index'

  match '/stats' => redirect { |params, req| "/#{req[:user]}/#{req[:project]}" }

  match '/:user/:project' => 'stats#report',
    :constraints => {
      :project => /[-_.A-z0-9]+/,
      :user    => /[-_.A-z0-9]+/
    }

end
