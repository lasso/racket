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
    # Namespace for view utilities
    module Views
      # Class responsible for rendering a controller/view/layout combination.
      class Renderer
        # Returns a service proc that can be used by the registry.
        #
        # @param  [Hash] _options (unused)
        # @return [Proc]
        def self.service(_options = {})
          -> { self }
        end

        # Renders a page using the provided controller/view and layout combination and returns an
        # response array that can be sent to the client.
        #
        # @param [Racket::Controller] controller
        # @param [String] view
        # @param [String] layout
        # @return [Array]
        def self.render(controller, view, layout)
          send_response(
            controller.response,
            view ? render_template(controller, view, layout) : controller.racket.action_result
          )
        end

        # Renders a template/layout combo using Tilt and returns it as a string.
        #
        # @param [Racket::Controller] controller
        # @param [String] view
        # @param [String|nil] layout
        # @return [String]
        def self.render_template(controller, view, layout)
          output = Tilt.new(view).render(controller)
          output = Tilt.new(layout).render(controller) { output } if layout
          output
        end

        # Sends response to client.
        #
        # @param [Racket::Response] response
        # @param [String] output
        # @return nil
        def self.send_response(response, output)
          response.write(output)
          response.finish
        end

        private_class_method :render_template, :send_response
      end
    end
  end
end
