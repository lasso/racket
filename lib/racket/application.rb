module Racket
  class Application

    def initialize(options = {})
      @router = Router.new
      if options.key?(:routes)
        options[:routes].each_pair { |key, val| @router.map(key, val) }
      end
    end

    def call(env)
      @router.route(Request.new(env))
    end
  end
end
