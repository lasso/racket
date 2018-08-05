# Racket - The noisy Rack MVC framework
# Copyright (C) 2015-2018  Lars Olsson <lasso@lassoweb.se>
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

require_relative 'base'

module Racket
  # Namespace for plugins.
  module Plugins
    # Sass plugin.
    class Sass < Base
      # Called on plugin initialization.
      def initialize(settings = nil)
        super
        begin
          require 'sass/plugin/rack'
        rescue LoadError
          raise 'Failed to load sass rack plugin!'
        end
        apply_sass_settings
      end

      # Middleware that should be automatically added.
      def middleware
        [[::Sass::Plugin::Rack, nil]]
      end

      private

      # Apply each setting to the Sass plugin.
      def apply_sass_settings
        settings.each_pair { |key, value| ::Sass::Plugin.options[key] = value }
      end
    end
  end
end
