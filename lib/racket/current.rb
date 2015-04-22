module Racket

  class Current

    def self.get(env)
      mod = Module.new
      request = Request.new(env)
      response = Response.new
      mod.class_eval do
        define_method(:request) { request }
        define_method(:response) { response }
      end
      mod
    end

  end

end
