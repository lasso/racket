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
  # Handles rendering in Racket applications.
  class ViewManager
    def initialize(locator, renderer)
      @locator = locator
      @renderer = renderer
    end

    # Renders a controller based on the request path and the variables set in the
    # controller instance.
    #
    # @param [Controller] controller
    # @return [Hash]
    def render(controller)
      @renderer.render(controller, *get_view_and_layout(controller))
    end

    private

    # Returns the view and layout that should be used for rendering.
    #
    # @param [Racket::Controller] controller
    # @return [Array]
    def get_view_and_layout(controller)
      view = @locator.get_view(controller)
      layout = view ? @locator.get_layout(controller) : nil
      [view, layout]
    end
  end
end
