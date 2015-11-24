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
  # Namespace for plugins.
  module Plugins
    # Sass plugin.
    module Sass
      # Called on plugin initialization.
      def self.init(settings)
        begin
          require 'sass/plugin/rack'
        rescue LoadError
          raise 'Failed to load sass rack plugin!'
        end
        settings.each_pair { |key, value| ::Sass::Plugin.options[key] = value }
      end

      # Helpers that should be *automatically* added to the controller.
      # If the plugin has halpers that should *not* be loaded automatically, this method
      # should not return those helpers.
      def self.helpers
        []
      end

      # Middleware that should be automatically added.
      def self.middleware
        [[::Sass::Plugin::Rack, nil]]
      end
    end
  end
end
