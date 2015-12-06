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
  # Helpers module
  module Helpers
    # Helper module that allows CSS files to be loaded dynamically using SASS.
    module Sass
      # Get route to CSS, which will use SASS in the background to deliver the CSS.
      #
      # @param [Symbol] sym
      # @return [String]
      def css(sym)
        "/css/#{Application.get_route(self.class)}/#{sym}.css"
      end

      # Whenever this helper is included in a controller it will setup a link between
      # a SASS directory and a CSS directory.
      #
      # @param [Class] klass
      # @return [nil]
      def self.included(klass)
        route = Application.get_route(klass)[1..-1] # Remove leading slash
        ::Sass::Plugin.add_template_location(
          Utils.build_path(Application.settings.root_dir, 'sass', route).to_s,
          Utils.build_path(Application.settings.root_dir, 'public', 'css', route).to_s
        )
        nil
      end
    end
  end
end
