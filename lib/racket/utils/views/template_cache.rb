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
    module Views
      # Cache for storing templates
      class TemplateCache
        def initialize
          @cache = {}
        end

        # Returns a cached template. If the template has not been cached yet, this method will run a
        # lookup against the provided parameters.
        #
        # @param [String] path
        # @param [TemplateParams] template_params
        # @return [String|Proc|nil]
        def ensure_in_cache(path, template_params)
          return @cache[path] if @cache.key?(path)
          @cache[path] = TemplateLocator.calculate_path(path, template_params)
        end
      end
    end
  end
end
