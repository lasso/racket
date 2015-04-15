require 'http_router'

module Racket
  class Router

    def initialize
      @router = HttpRouter.new
    end

    def map(path, klass)
      @router.add(path).to(klass)
    end

    def route(request)
      # Find controller in map
      # If controller exists, call it
      # Otherwise, send a 404
      matching_routes = @router.recognize(request.env)
      unless matching_routes.first.nil?
        target_klass = matching_routes.first.first.route.dest
        target = target_klass.new
        params = matching_routes.first.first.param_values.first.reject { |e| e.empty? }
        action = params.empty? ? :index : params.shift.to_sym 
        [
          200,
          {},
          [
            "<pre>Routing to #{target_klass.inspect}" \
            " using action #{action.inspect} and params #{params}.</pre>"
          ]
        ]
      else
        [404, {}, 'Not found']
      end
    end

  end
end
