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
        route = Application.get_route(self.class)
        route = '' if route == '/' # Special case for root controller
        "/css#{route}/#{sym}.css"
      end

      # Whenever this helper is included in a controller it will setup a link between
      # a SASS directory and a CSS directory.
      #
      # @param [Class] klass
      # @return [nil]
      def self.included(klass)
        route = Application.get_route(klass)[1..-1] # Remove leading slash
        root_dir = Application.settings.root_dir
        sass_dir = Utils.build_path(root_dir, 'sass', route).to_s
        css_dir = Utils.build_path(root_dir, 'public', 'css', route).to_s
        ::Sass::Plugin.add_template_location(sass_dir, css_dir)
        Dir.chdir(sass_dir) do
          basedir = route.empty? ? '/css' : "/css/#{route}"
          Dir.glob('*.s[ac]ss').each do |file|
            Application.settings.warmup_urls << "#{basedir}/#{::File.basename(file, '.*')}.css"
          end
        end
        nil
      end
    end
  end
end
