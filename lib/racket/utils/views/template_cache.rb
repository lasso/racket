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
      # Class for caching templates.
      # This class adheres to the Moneta API
      # (https://github.com/minad/moneta#user-content-moneta-api), even though it is not using the
      # Moneta framework.
      class TemplateCache
        def initialize(options)
          @items = {}
          @options = options
        end

        def [](key)
          @items[key]
        end

        def load(key, options = {})
          @items[key]
        end

        def fetch(key, options, &blk)
          return @items[key] if items.key?(key)
          block.call
        end

        def []=(key, value)
          @items[key] = value
        end

        def store(key, value, options = {})
          @items[key] = value
        end

        def delete(key, value, options = {})
          @items.delete(key)
        end

        def key?(key)
          @items.key?(key)
        end
      end
    end
  end
end
