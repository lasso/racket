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

require 'set'

require 'http_router'

module Racket
  # Handles routing in Racket applications.
  class Router
    # A struct describing a route.
    Route = Struct.new(:root, :action, :params) do
      def to_s
        route = root.dup
        route << "/#{action}" if action
        route << "/#{params.join('/')}" unless params.empty?
        route = route[1..-1] if route.start_with?('//') # Special case for root path
        route
      end
    end

    attr_reader :action_cache
    attr_reader :routes

    def initialize(action_cache, logger)
      @action_cache = action_cache
      @logger = logger
      @router = HttpRouter.new
      @routes = {}
    end

    # Returns a route to the specified controller/action/parameter combination.
    #
    # @param [Class] controller_class
    # @param [Symbol] action
    # @param [Array] params
    # @return [String]
    def get_route(controller_class, action, params)
      fail "Cannot find controller #{controller_class}" unless @routes.key?(controller_class)
      params.flatten!
      Route.new(@routes[controller_class], action, params).to_s
    end

    # Maps a controller to the specified path.
    #
    # @param [String] path
    # @param [Class] controller_class
    # @return [nil]
    def map(path, controller_class)
      map_controller(path.empty? ? '/' : path, controller_class)
      @router.add("#{path}(/*params)").to(controller_class)
      @action_cache.add(controller_class)
    end

    # @todo: Allow the user to set custom handlers for different errors
    def render_error(status, error = nil)
      # If running in dev mode, let Rack::ShowExceptions handle the error.
      fail(error) if error && Application.dev_mode?

      # Not running in dev mode, let us handle the error ourselves.
      Response.generate_error_response(status)
    end

    # Routes a request and renders it.
    #
    # @param [Hash] env Rack environment
    # @return [Array] A Rack response triplet
    def route(env)
      catch :response do # Catches early exits from Controller.respond.
        # Ensure that that a controller will respond to the request. If not, send a 404.
        return render_error(404) unless (target_info = target_info(env))
        Utils.render_controller(env, target_info)
      end
    rescue => err
      render_error(500, err)
    end

    private

    def map_controller(base_path, controller_class)
      @logger.inform_dev("Mapping #{controller_class} to #{base_path}.")
      @routes[controller_class] = base_path
    end

    # Returns information about the target of the request. If no valid target can be found, +nil+
    # is returned.
    #
    # @param [Hash] env
    # @return [Array|nil]
    def target_info(env)
      matching_route = @router.recognize(env).first
      # Exit early if no controller is responsible for the route
      return nil unless matching_route
      # Some controller is claiming to be responsible for the route
      result = Utils.extract_target(matching_route.first)
      # Exit early if action is not available on target
      return nil unless @action_cache.present?(result.first, result.last)
      result
    end
  end
end
