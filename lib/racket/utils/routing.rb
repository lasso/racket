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
      # Class for caching actions
      class ActionCache
        attr_reader :items

        def initialize
          @items = {}
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
        # @param [Racket::Controller]
        # @return [nil]
        def add(controller_class)
          actions = SortedSet.new
          current_class = controller_class
          while current_class < Controller
            actions.merge(current_class.public_instance_methods(false))
            current_class = current_class.superclass
          end
          actions = actions.to_a
          Application.inform_dev("Caching actions #{actions} for #{controller_class}.")
          (@items[controller_class] = actions) && nil
        end
      end

      # Returns a new ActionCache object.
      #
      # @return [ActionCache]
      def self.create_action_cache
        ActionCache.new
      end

      # Extracts the target class, target params and target action from a list of valid routes.
      #
      # @param [HttpRouter::Response] response
      # @return [Array]
      def self.extract_target(response)
        target_klass = response.route.dest
        params = response.param_values.first.reject(&:empty?)
        action = params.empty? ? target_klass.settings.fetch(:default_action) : params.shift.to_sym
        [target_klass, params, action]
      end

      # Updates the PATH_INFO environment variable.
      #
      # @param [Hash] env
      # @param [Fixnum] num_params
      # @return [nil]
      def self.update_path_info(env, num_params)
        env['PATH_INFO'] = env['PATH_INFO']
                           .split('/')[0...-num_params]
                           .join('/') unless num_params.zero?
        nil
      end
    end
  end
end
