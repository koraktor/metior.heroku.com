module ActionController

  module CurrentView

    def render(*args)
      @current_view = args.first
      if @current_view.is_a? Hash
        @current_view = @current_view[:template] || action_name
      end
      @current_view = @current_view.to_sym

      super
    end

  end

  Rendering.send :include, CurrentView

end
