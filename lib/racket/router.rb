require 'http_router'

module Racket
  class Router

    def initialize(controller_dir)
      @router = HttpRouter.new
      create_routes_from_controllers(controller_dir)
    end

    def map(path, klass)
      @router.add(path).to(klass)
    end

    def route(request)
      # Find controller in map
      # If controller exists, call it
      # Otherwise, send a 404
      matching_routes = @router.recognize(request)
      unless matching_routes.first.nil?
        target_klass = matching_routes.first.first.route.dest
        target = target_klass.new
        [200, {}, [target.inspect]]
      else
        [404, {}, 'Not found']
      end
    end

    private

    def create_routes_from_controllers(controller_dir)
      Dir.chdir (controller_dir) do
        files = Dir.glob(File.join('**', '*.rb'))
        files.each do |file|
          require File.join(controller_dir, file)
          path = File.dirname(file)
          path = '' if path == '.'
          map('/' << path, Utils.class_from_string(File.basename(file, '.rb')))
        end
      end
    end

  end
end
