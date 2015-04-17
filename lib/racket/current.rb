require 'digest/sha1'

module Racket

  class Current

    def self.get(env)
      mod = Module.new
      mod.class_eval do
        define_method(:request) { Request.new(env) }
        define_method(:response) { Response.new }
      end
      mod
    end

  end

end
