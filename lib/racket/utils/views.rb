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

require 'tilt'

module Racket
  module Utils
    # Utility functions for views.
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

      # Class used for locating templates.
      class TemplateLocator
        def initialize(layout_base_dir, view_base_dir)
          @layout_base_dir = layout_base_dir
          @view_base_dir = view_base_dir
          @layout_cache = TemplateCache.new
          @view_cache = TemplateCache.new
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
          klass = self.class
          path = klass.get_template_path(template_params.controller)
          template = template_params.cache.ensure_in_cache(path, template_params)
          klass.resolve_template(path, template, template_params)
        end

        def self.calculate_path(path, template_params)
          type, controller, base_dir = template_params.to_a
          default_template = controller.settings.fetch("default_#{type}".to_sym)
          template =
            TemplateLocator.lookup_template_with_default(
              Utils.fs_path(base_dir, path), default_template
            )
          ::Racket::Application.inform_dev(
            "Using #{type} #{template.inspect} for #{controller.class}.#{controller.racket.action}."
          )
          template
        end

        def self.resolve_template(path, template, template_params)
          return template unless template.is_a?(Proc)
          _, controller, base_dir = template_params.to_a
          lookup_template(
            Utils.fs_path(
              Utils.fs_path(base_dir, path).dirname,
              call_template_proc(template, controller)
            )
          )
        end

        # Calls a template proc. Depending on how many parameters the template proc takes, different
        # types of information will be passed to the proc.
        # If the proc takes zero parameters, no information will be passed.
        # If the proc takes one parameter, it will contain the current action.
        # If the proc takes two parameters, they will contain the current action and the current
        #   params.
        # If the proc takes three parameters, they will contain the current action, the current
        # params and the current request.
        #
        # @param [Proc] proc
        # @param [Racket::Controller] controller
        # @return [String]
        def self.call_template_proc(proc, controller)
          racket = controller.racket
          proc_args = [racket.action, racket.params, controller.request].slice(0...proc.arity)
          proc.call(*proc_args).to_s
        end

        # Returns the "url path" that should be used when searching for templates.
        #
        # @param [Racket::Controller] controller
        # @return [String]
        def self.get_template_path(controller)
          template_path =
            [::Racket::Application.get_route(controller.class), controller.racket.action].join('/')
          template_path = template_path[1..-1] if template_path.start_with?('//')
          template_path
        end

        # Locates a file in the filesystem matching an URL path. If there exists a matching file,
        # the path to it is returned. If there is no matching file, +nil+ is returned.
        # @param [Pathname] path
        # @return [Pathname|nil]
        def self.lookup_template(path)
          Utils.first_matching_path(*Utils.extract_dir_and_glob(path))
        end

        # Locates a file in the filesystem matching an URL path. If there exists a matching file,
        # the path to it is returned. If there is no matching file and +default_template+ is a
        # String or a Symbol, another lookup will be performed using +default_template+. If
        # +default_template+ is a Proc or nil, +default_template+ will be used as is instead.
        #
        # @param [Pathname] path
        # @param [String|Symbol|Proc|nil] default_template
        # @return [String|Proc|nil]
        def self.lookup_template_with_default(path, default_template)
          template = lookup_template(path)
          if !template && (default_template.is_a?(String) || default_template.is_a?(Symbol))
            template = lookup_template(Utils.fs_path(path.dirname, default_template))
          end
          template || default_template
        end
      end

      # Class responsible for rendering a controller/view/layout combination.
      class ViewRenderer
        # Renders a page using the provided controller/view and layout combination and returns an
        # response array that can be sent to the client.
        #
        # @param [Racket::Controller] controller
        # @param [String] view
        # @param [String] layout
        # @return [Array]
        def self.render(controller, view, layout)
          send_response(
            controller.response,
            view ? render_template(controller, view, layout) : controller.racket.action_result
          )
        end

        # Renders a template/layout combo using Tilt and returns it as a string.
        #
        # @param [Racket::Controller] controller
        # @param [String] view
        # @param [String|nil] layout
        # @return [String]
        def self.render_template(controller, view, layout)
          output = Tilt.new(view).render(controller)
          output = Tilt.new(layout).render(controller) { output } if layout
          output
        end

        # Sends response to client.
        #
        # @param [Racket::Response] response
        # @param [String] output
        # @return nil
        def self.send_response(response, output)
          response.write(output)
          response.finish
        end

        private_class_method :render_template, :send_response
      end

      # Struct for holding template data.
      TemplateParams = Struct.new(:type, :controller, :base_dir, :cache)
    end
  end
end
