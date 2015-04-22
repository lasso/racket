module Racket
  class Controller

    def self.inherited(klass)
      Application.options[:last_added_controller] = klass
    end

    def default_action
      Application.options[:default_action]
    end

    def render(action)
      __execute(action)
      Application.view_cache.render(self)
    end

    private

    def __execute(action)
      meth = method(action)
      response.action_result = case meth.arity
        when 0 then meth.call
        else meth.call(params[0...meth.arity])
      end
    end

  end
end
