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

    def route(env)
      # Find controller in map
      # If controller exists, call it
      # Otherwise, send a 404
      matching_routes = @router.recognize(env)
      unless matching_routes.first.nil?
        target_klass = matching_routes.first.first.route.dest
        target = target_klass.new
        target.extend(Current.get(env))
        params = matching_routes.first.first.param_values.first.reject { |e| e.empty? }
        action = params.empty? ? :index : params.shift.to_sym
        # Check if action is available on target
        return [404, {}, 'No such action'] unless @actions_by_controller[target_klass].include?(action)
        meth = target.method(action)
        if meth.arity.zero?
          result = meth.call
        else
          result = meth.call(params[0...meth.arity])
        end
        [200, {}, [result]]
      else
        [404, {}, 'Not found']
      end
    end

  end
end
