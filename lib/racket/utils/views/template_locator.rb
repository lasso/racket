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
          fail ArgumentError, 'Layout base path is missing.' unless
            (@layout_base_dir = options.fetch(:layout_base_dir, nil))
          fail ArgumentError, 'View base path is missing.' unless
            (@view_base_dir = options.fetch(:view_base_dir, nil))
          fail ArgumentError, 'Template resolver is missing.' unless
            (@template_resolver = options.fetch(:template_resolver, nil))
          @layout_cache = options.fetch(:layout_cache, Moneta.new(:Null))
          @view_cache = options.fetch(:view_cache, Moneta.new(:Null))
        end

        # Returns the layout associated with the current request. On the first request to any action
        # the result is cached, meaning that the layout only needs to be looked up once.
        #
        # @param [Racket::Controller] controller
        # @return [String|nil]
        def get_layout(controller)
          get_template(TemplateParams.new(:layout, controller, @layout_base_dir, @layout_cache))
        end

        # Returns the view associated with the current request. On the first request to any action
        # the result is cached, meaning that the view only needs to be looked up once.
        #
        # @param [Racket::Controller] controller
        # @return [String|nil]
        def get_view(controller)
          get_template(TemplateParams.new(:view, controller, @view_base_dir, @view_cache))
        end

        private

        # Tries to locate a template matching +path+ in the file system and returns the path if a
        # matching file is found. If no matching file is found, +nil+ is returned. The result is
        # cached, meaning that the filesystem lookup for a specific path will only happen once.
        #
        # @param [TemplateParams] template_params
        # @return [String|nil]
        def get_template(template_params)
          path = @template_resolver.get_template_path(template_params.controller)
          cache = template_params.cache
          unless cache.key?(path)
            template = @template_resolver.calculate_path(path, template_params)
            cache.store(
              path,
              @template_resolver.resolve_template(path, template, template_params)
            )
          end
          cache.load(path)
        end
      end
    end
  end
end
