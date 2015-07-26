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
  # Helper module
  module Helpers
    # Module for handling routing
    module Routing
      # Returns a route to an action within another controller.
      #
      # @param [Class] controller
      # @param [Symbol] action
      # @param [Array] params
      # @return [String]
      def route(controller, action, *params)
        Application.get_route(controller, action, params)
      end

      alias_method(:r, :route)

      # Returns a route to an action within the current controller.
      #
      # @param [Symbol] action
      # @param [Array] params
      # @return [String]
      def route_self(action, *params)
        Application.get_route(self.class, action, params)
      end

      alias_method(:rs, :route_self)
    end
  end
end
