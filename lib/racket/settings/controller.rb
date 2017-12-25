# Racket - The noisy Rack MVC framework
# Copyright (C) 2015-2017  Lars Olsson <lasso@lassoweb.se>
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

require_relative 'base.rb'

module Racket
  module Settings
    # Class for storing controller settings.
    # This settings class will lookup settings further up in the inheritance chain and will use
    # the application settings as a final fallback.
    class Controller < Base
      def initialize(owner, defaults = {})
        super(defaults)
        @owner = owner
      end

      # Fetches settings from the current object. If the setting cannot be found in the current
      # object, the objects class/superclass will be queried. If all controller classes in the
      # inheritance chain has been queried, the application settings will be used as a final
      # fallback.
      def fetch(key, default = nil)
        return @custom[key] if @custom.key?(key)
        parent = parent_class(@owner)
        return @owner.context.application_settings.fetch(key, default) if controller_base?(@owner)
        return parent.context.application_settings.fetch(key, default) if controller_base?(parent)
        parent.settings.fetch(key, default)
      end

      private

      # Returns whether the provided argument is a Racket::Controller class
      #
      # @param [Class] klass
      # @return true|false
      def controller_base?(klass)
        klass == ::Racket::Controller
      end

      # Returns the "parent" class of object
      # @param [Object] object
      # @return [Class]
      def parent_class(obj)
        obj.is_a?(Class) ? obj.superclass : obj.class
      end
    end
  end
end
