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
      # Class used for locating templates. This class uses the TemplateResolver class internally
      # for getting the template for the first time and caches the result so that subsequent Calls
      # will not need to resolve the template again.
      class TemplateLocator
        def initialize(options)
          fail ArgumentError, 'Layout cache is missing.' unless
            (@layout_cache = options.fetch(:layout_cache, nil))
          fail ArgumentError, 'Layout resolver is missing.' unless
            (@layout_resolver = options.fetch(:layout_resolver, nil))
          fail ArgumentError, 'View cache is missing.' unless
            (@view_cache = options.fetch(:view_cache, nil))
          fail ArgumentError, 'View resolver is missing.' unless
            (@view_resolver = options.fetch(:view_resolver, nil))
        end

        # Returns the layout associated with the current request. On the first request to any action
        # the result is cached, meaning that the layout only needs to be looked up once.
        #
        # @param [Racket::Controller] controller
        # @return [String|nil]
        def get_layout(controller)
          get_template(:layout, controller)
        end

        # Returns the view associated with the current request. On the first request to any action
        # the result is cached, meaning that the view only needs to be looked up once.
        #
        # @param [Racket::Controller] controller
        # @return [String|nil]
        def get_view(controller)
          get_template(:view, controller)
        end

        private

        def get_cache_and_resolver_by_type(type)
          case type
          when :layout then [@layout_cache, @layout_resolver]
          when :view then [@view_cache, @view_resolver]
          end
        end

        # Tries to locate a template matching +path+ in the file system and returns the path if a
        # matching file is found. If no matching file is found, +nil+ is returned. The result is
        # cached, meaning that the filesystem lookup for a specific path will only happen once.
        #
        # @param [TemplateParams] template_params
        # @return [String|nil]
        def get_template(type, controller)
          cache, resolver = get_cache_and_resolver_by_type(type)
          path = resolver.get_template_path(controller)
          unless cache.key?(path)
            template = resolver.get_template_object(path, controller)
            cache.store(path, template)
          end
          resolver.resolve_template(path, cache.load(path), controller)
        end
      end
    end
  end
end
