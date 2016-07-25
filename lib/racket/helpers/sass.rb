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
        route = self.class.get_route
        route = '' if route == '/' # Special case for root controller
        "/css#{route}/#{sym}.css"
      end

      def self.add_template_location(klass, route)
        root_dir = klass.settings.fetch(:root_dir)
        utils = klass.context.utils
        sass_dir = utils.build_path(root_dir, 'sass', route).to_s
        css_dir = utils.build_path(root_dir, 'public', 'css', route).to_s
        ::Sass::Plugin.add_template_location(sass_dir, css_dir)
        sass_dir
      end

      def self.add_warmup_urls(klass, sass_dir, route)
        Dir.chdir(sass_dir) do
          basedir = route.empty? ? '/css' : "/css/#{route}"
          Dir.glob('*.s[ac]ss').each do |file|
            klass.settings.fetch(:warmup_urls) << "#{basedir}/#{::File.basename(file, '.*')}.css"
          end
        end
      end

      # Whenever this helper is included in a controller it will setup a link between
      # a SASS directory and a CSS directory.
      #
      # @param [Class] klass
      # @return [nil]
      def self.included(klass)
        route = klass.get_route()[1..-1] # Remove leading slash
        sass_dir = add_template_location(klass, route)
        add_warmup_urls(klass, sass_dir, route)
        nil
      end

      private_class_method :add_template_location, :add_warmup_urls
    end
  end
end
