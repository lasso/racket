module Racket
  class Application

    def initialize(options = {})
      @options = default_options.merge(options)
      @router = Router.new(@options[:controller_dir])
    end

    def call(env)
      @router.route(Request.new(env))
    end

    private

    def default_options
      {
        controller_dir: File.join(Dir.pwd, 'controllers'),
        view_dir: File.join(Dir.pwd, 'views')
      }
    end
  end
end
