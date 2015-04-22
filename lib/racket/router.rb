require 'http_router'

module Racket
  class Router

    def initialize
      @router = HttpRouter.new
      @actions_by_controller = {}
    end

    # Caches available actions for each controller class. This also works for controller classes
    # that inherit from other controller classes.
    def cache_actions(klass)
      actions = Set.new
      current = klass
      while current < Controller
        actions.merge(current.instance_methods(false))
        current = current.superclass
      end
      @actions_by_controller[klass] = actions.to_a
    end

    def map(path, klass)
      @router.add(path).to(klass)
      cache_actions(klass)
    end

    # @todo: Allow the user to set custom handlers for different errors
    def render_404(message = '404 Not found')
      [404, { 'Content-Type' => 'text/plain' }, message]
    end

    def route(env)
      # Find controller in map
      # If controller exists, call it
      # Otherwise, send a 404
      matching_routes = @router.recognize(env)
      unless matching_routes.first.nil?
        target_klass = matching_routes.first.first.route.dest
        params = matching_routes.first.first.param_values.first.reject { |e| e.empty? }
        action = params.empty? ? target.default_action : params.shift.to_sym

        # Check if action is available on target
        return render_404 unless @actions_by_controller[target_klass].include?(action)

        # Initialize target
        target = target_klass.new
        env['racket.action'] = action
        env['racket.params'] = params
        # @fixme: File.dirname should not be used on urls!
        1.upto(params.count) do
          env['PATH_INFO'] = File.dirname(env['PATH_INFO'])
        end
        target.extend(Current.get(env))
        target.render(action)
      else
        render_404
      end
    end

  end
end
