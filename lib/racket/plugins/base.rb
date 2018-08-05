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

module Racket
  # Namespace for plugins.
  module Plugins
    # Plugin base class. All plugins should inherit from this class.
    class Base
      attr_reader :settings

      def initialize(settings = {})
        @settings = {}
        @settings.merge!(settings) if settings.is_a?(Hash)
      end

      # This method should return an array of helpers (symbols) that the plugin wants to load
      # automatically in every controller. If you do not want your controller to load any helpers
      # automatically you do not need to override this method. You can still add your helpers to
      # individual controllers by using Controller#helper.
      #
      # @return [Array] An array of symbols representing helpers that should be loaded automatically
      def default_controller_helpers
        []
      end

      # This method should return an array of [Module, Hash] arrays where each module represenents
      # a Rack-compatible middleware module and the hash the settings that should be applied to
      # that middleware. Each pair that the plugin provides will be automatically added to the
      # middleware of the application. This is just for conveniance, a user could still add The same
      # middleware using the global settings.
      #
      # @return [Array] An array of [Module, Hash] pairs that represenents middleware that will be
      #   loaded automatically by the plugin
      def middleware
        []
      end
    end
  end
end
