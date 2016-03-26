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

module Racket
  module Utils
    # Utility functions for routing.
    module Routing
      # Struct for keeping track router parameters.
      RouterParams = Struct.new(:action, :params, :env)

      # Class for caching actions
      class ActionCache
        attr_reader :items

        def initialize(logger)
          @items = {}
          @logger = logger
        end

        # Returns whether +controller_class+ is in the cache and that it contains the action
        # +action+.
        #
        # @param [Class] controller_class
        # @param [Symbol] action
        # @return [true|false]
        def present?(controller_class, action)
          @items.fetch(controller_class, []).include?(action)
        end

        # Caches all actions for a controller class. This is used on every request to quickly decide
        # whether an action is valid or not.
        #
        # @param [Class] controller_class
        # @return [nil]
        def add(controller_class)
          __add(controller_class)
          actions = @items[controller_class].to_a
          @items[controller_class] = actions
          @logger.inform_dev(
            "Registering actions #{actions} for #{controller_class}."
          ) && nil
        end

        private

        # Internal handler for adding actions to the cache.
        #
        # @param [Class] controller_class
        # @return [nil]
        def __add(controller_class)
          return if controller_class == Controller
          actions = @items.fetch(controller_class, SortedSet.new)
          @items[controller_class] = actions.merge(controller_class.public_instance_methods(false))
          __add(controller_class.superclass) && nil
        end
      end

      # Extracts the target class, target params and target action from a list of valid routes.
      #
      # @param [HttpRouter::Response] response
      # @return [Array]
      def extract_target(response)
        target_klass = response.route.dest
        params = response.param_values.first.reject(&:empty?)
        action = params.empty? ? target_klass.settings.fetch(:default_action) : params.shift.to_sym
        [target_klass, params, action]
      end

      def call_controller(target_klass, mod)
        target = target_klass.new
        target.extend(mod)
        target.__run
      end

      # Renders a controller. This is the default action whenever a matching route for a request
      # is found.
      #
      # @param [Hash] env
      # @param [Array] target_info
      # @return [Array] A racket response triplet
      def render_controller(env, target_info)
        controller_class, params, action = target_info

        # Rewrite PATH_INFO to reflect that we split out the parameters
        update_path_info(env, params.length)

        # Initialize and render target
        call_controller(
          controller_class,
          Current.init(RouterParams.new(action, params, env))
        )
      end

      # Updates the PATH_INFO environment variable.
      #
      # @param [Hash] env
      # @param [Fixnum] num_params
      # @return [nil]
      def update_path_info(env, num_params)
        env['PATH_INFO'] = env['PATH_INFO']
                           .split('/')[0...-num_params]
                           .join('/') unless num_params.zero?
        nil
      end

      # @TODO: Remove when Racket::Utils stops being a singleton
      extend self
    end
  end
end
