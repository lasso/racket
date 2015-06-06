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

    # Returns an option for the current controller class or any of the controller classes
    # it is inheriting from.
    #
    # @param [Symbol] key The option to retrieve
    # @return [Object]
    def self.get_option(key)
      @options ||= {}
      return @options[key] if @options.key?(key)
      # We are running out of controller options, do one final lookup in Application.options
      return Application.options.fetch(key, nil) if superclass == Controller
      superclass.get_option(key)
    end

    # Sets an option for the current controller class.
    #
    # @param [Symbol] key
    # @param [Object] value
    def self.set_option(key, value)
      @options ||= {}
      @options[key] = value
    end

    # Returns an option from the current controller class.
    #
    # @param [Symbol] key
    # @return
    def controller_option(key)
      self.class.get_option(key)
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
      racket.redirected = true
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
      params = racket.params[0...meth.parameters.length]
      racket.action_result = meth.call(*params)
    end

  end
end
