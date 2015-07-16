# Racket - The noisy Rack MVC framework
# Copyright (C) 2015  Lars Olsson <lasso@lassoweb.se>
#
# This file is part of Racket.
#
# Racket is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Racket is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Racket.  If not, see <http://www.gnu.org/licenses/>.

require 'http_router'

module Racket
  # Handles routing in Racket applications.
  class Router
    def initialize
      @router = HttpRouter.new
      @routes_by_controller = {}
      @actions_by_controller = {}
    end

    # Caches available actions for each controller class. This also works for controller classes
    # that inherit from other controller classes.
    #
    # @param [Class] controller
    # @return [nil]
    def cache_actions(controller)
      actions = Set.new
      current = controller
      while current < Controller
        actions.merge(current.instance_methods(false))
        current = current.superclass
      end
      (@actions_by_controller[controller] = actions.to_a) && nil
    end

    # Returns a route to the specified controller/action/parameter combination.
    #
    # @param [Class] controller
    # @param [Symbol] action
    # @param [Array] params
    # @return [String]
    def get_route(controller, action, params)
      route = ''
      route << @routes_by_controller[controller] if @routes_by_controller.key?(controller)
      action = action.to_s
      route << "/#{action}" unless action.empty?
      route << "/#{params.join('/')}" unless params.empty?
      route = route[1..-1] if route.start_with?('//') # Special case for root path
      route
    end

    # Maps a controller to the specified path.
    #
    # @param [String] path
    # @param [Class] controller
    # @return [nil]
    def map(path, controller)
      controller_base_path = path.empty? ? '/' : path
      Application.inform_dev("Mapping #{controller} to #{controller_base_path}.")
      @router.add("#{path}(/*params)").to(controller)
      @routes_by_controller[controller] = controller_base_path
      cache_actions(controller) && nil
    end

    # @todo: Allow the user to set custom handlers for different errors
    def render_error(status, error = nil)
      # If running in dev mode, let Rack::ShowExceptions handle the error.
      fail(error) if error && Application.dev_mode?

      # Not running in dev mode, let us handle the error ourselves.
      response = Response.new([], status, 'Content-Type' => 'text/plain')
      response.write("#{status} #{Rack::Utils::HTTP_STATUS_CODES[status]}")
      response.finish
    end

    # Routes a request and renders it.
    #
    # @param [Hash] env Rack environment
    # @return [Array] A Rack response triplet
    def route(env)
      catch :response do # Catches early exits from Controller.respond.
        # Find controller in map
        # If controller exists, call it
        # Otherwise, send a 404
        matching_routes = @router.recognize(env)

        # Exit early if no controller is responsible for the route
        return render_error(404) if matching_routes.first.nil?

        # Some controller is claiming to be responsible for the route
        target_klass = matching_routes.first.first.route.dest
        params = matching_routes.first.first.param_values.first.reject(&:empty?)
        action = params.empty? ? target_klass.get_option(:default_action) : params.shift.to_sym

        # Check if action is available on target
        return render_error(404) unless @actions_by_controller[target_klass].include?(action)

        # Rewrite PATH_INFO to reflect that we split out the parameters
        env['PATH_INFO'] = env['PATH_INFO']
                           .split('/')[0...-params.count]
                           .join('/') unless params.empty?

        # Initialize and render target
        target = target_klass.new
        target.extend(Current.init(env, action, params))
        target.__run
      end
      rescue => err
        render_error(500, err)
    end
  end
end
