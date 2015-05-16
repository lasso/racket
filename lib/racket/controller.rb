=begin
Racket - The noisy Rack MVC framework
Copyright (C) 2015  Lars Olsson <lasso@lassoweb.se>

This file is part of Racket.

Racket is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Racket is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with Racket.  If not, see <http://www.gnu.org/licenses/>.
=end

module Racket

  # Base controller class. Your controllers should inherit this class.
  class Controller

    # :nodoc:
    def self.inherited(klass)
      Application.options[:last_added_controller].push(klass)
    end

    # Returns the default action for the current controller class.
    #
    # @return [Symbol]
    def self.default_action
      get_inherited_option(:default_action) || Application.options[:default_action]
    end

    # Returns an option for the current controller class or any of the controller classes
    # it is inheriting from.
    #
    # @param [Symbol] option_name The option to retrieve
    # @return [Object]
    def self.get_inherited_option(option_name)
      val = get_option(option_name)
      return val if val
      return nil if superclass == Controller # End of the line
      superclass.get_inherited_option(option_name)
    end

    # Returns an option for the current controller class.
    #
    # @param [Symbol] option_name The option to retrieve
    # @return [Object]
    def self.get_option(option_name)
      @options ||= {}
      return @options.fetch(option_name.to_sym, nil)
    end

    # Sets an option for the current controller class.
    #
    # @param [Symbol] option_name
    # @param [Object] option_value
    def self.set_option(option_name, option_value)
      @options ||= {}
      @options[option_name.to_sym] = option_value
    end

    # Returns a route to an action within the current controller.
    #
    # @param [Symbol] action
    # @param [Array] params
    # @return [String]
    def rs(action, *params)
      Application.get_route(self.class, action, params)
    end

    # Returns a route to an action within another controller.
    #
    # @param [Class] controller
    # @param [Symbol] action
    # @param [Array] params
    # @return [String]
    def r(controller, action, *params)
      Application.get_route(controller, action, params)
    end

    # Redirects the client.
    #
    # @param [String] target
    # @param [Fixnum] status
    # @return [Object]
    def redirect(target, status = 302)
      response.redirect(target, status)
    end

    # Renders an action.
    #
    # @param [Symbol] action
    # @return [String]
    def render(action)
      __execute(action)
      Application.view_cache.render(self)
    end

    private

    def __execute(action)
      meth = method(action)
      params = request.params[0...meth.parameters.length]
      response.action_result = meth.call(*params)
    end

  end
end
