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
    module Router
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

      module_function :extract_target, :update_path_info
    end
  end
end
