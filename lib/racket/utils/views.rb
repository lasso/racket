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

require 'tilt'

require_relative 'views/renderer.rb'
require_relative 'views/template_cache.rb'
require_relative 'views/template_locator.rb'
require_relative 'views/template_resolver.rb'

module Racket
  module Utils
    # Namespace for view utilities
    module Views
      # Extracts what template settings to use based on context and incoming parameters.
      #
      # @param [Object] context
      # @param [Hash] template_settings
      # @return [Hash]
      def self.extract_template_settings(context, template_settings)
        return template_settings if template_settings
        begin
          context.view_settings
        rescue NoMethodError
          {}
        end
      end
    end
  end
end
