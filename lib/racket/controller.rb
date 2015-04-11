module Racket
  class Controller

    def self.inherited(klass)
      Application.instance.instance_eval { @controller = klass }
    end

    def default_action
      Application.options[:default_action]
    end

  end
end
