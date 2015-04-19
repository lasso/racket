module Racket
  class Controller

    def self.inherited(klass)
      Application.options[:last_added_controller] = klass
    end

    def default_action
      Application.options[:default_action]
    end

  end
end
