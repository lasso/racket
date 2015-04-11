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
        [200, {}, [target.inspect]]
      else
        [404, {}, 'Not found']
      end
    end

  end
end
