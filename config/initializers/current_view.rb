module ActionController

  module CurrentView

    def render(*args)
      @current_view = args.first
      super
    end

  end

  Rendering.send :include, CurrentView

end
