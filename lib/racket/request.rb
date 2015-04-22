module Racket
  class Request < Rack::Request

    def params
      env['racket.params']
    end

    def action
      env['racket.action']
    end

    def action_result
      env['racket.action_result']
    end

  end
end
