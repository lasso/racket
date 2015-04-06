module Racket
  class Application

    def initialize
      @router = Router.new
    end

    def call(env)
      @router.route(Request.new(env))
    end
  end
end
