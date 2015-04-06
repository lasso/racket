module Racket
  class Router

    def initialize
      @url_map = Rack::URLMap.new
    end

    def route(request)
      # Find controller in map
      # If controller exists, call it
      # Otherwise, send a 404
      Response.new(request.inspect)
    end

  end
end
