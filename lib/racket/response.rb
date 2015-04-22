module Racket
  class Response < Rack::Response

    attr_accessor :action_result

  end
end
