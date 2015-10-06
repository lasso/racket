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
  # Handles rendering in Racket applications.
  class ViewManager
    # Struct for holding view parameters.
    ViewParams = Struct.new(:controller, :path, :type)

    attr_reader :layout_cache
    attr_reader :view_cache

    def initialize(layout_base_dir, view_base_dir)
      @layout_base_dir = layout_base_dir
      @view_base_dir = view_base_dir
      @layout_cache = {}
      @view_cache = {}
    end

    # Renders a controller based on the request path and the variables set in the
    # controller instance.
    #
    # @param [Controller] controller
    # @return [Hash]
    def render(controller)
      template_path = Utils.get_template_path(controller)
      view = get_template(ViewParams.new(controller, template_path, :view))
      layout = view ? get_template(ViewParams.new(controller, template_path, :layout)) : nil
      if view then output = Utils.render_template(controller, view, layout)
      else output = controller.racket.action_result
      end
      Utils.send_response(controller.response, output)
    end

    private

    # Returns a cached template. If the template has not been cached yet, this method will run a
    # lookup against the provided parameters.
    #
    # @param [ViewParams] view_params
    # @return [String|Proc|nil]
    def ensure_in_cache(view_params)
      _, path, type = view_params.to_a
      store = instance_variable_get("@#{type}_cache".to_sym)
      return store[path] if store.key?(path)
      store_in_cache(store, view_params)
    end

    # Tries to locate a template matching +path+ in the file system and returns the path if a
    # matching file is found. If no matching file is found, +nil+ is returned. The result is cached,
    # meaning that the filesystem lookup for a specific path will only happen once.
    #
    # @param [ViewParams] view_params
    # @return [String|nil]
    def get_template(view_params)
      template = ensure_in_cache(view_params)
      # If template is a Proc, call it
      if template.is_a?(Proc)
        controller, path, type = view_params.to_a
        template =
          Utils.lookup_template(
            instance_variable_get("@#{type}_base_dir".to_sym),
            [File.dirname(path), Utils.call_template_proc(template, controller)].join('/')
          )
      end
      template
    end

    # Stores the location of a template (not its contents) in the cache.
    #
    # @param [Object] store Where to store the location
    # @param [ViewParams] view_params
    # @return [String|Proc|nil]
    def store_in_cache(store, view_params)
      controller, path, type = view_params.to_a
      base_dir = instance_variable_get("@#{type}_base_dir".to_sym)
      default_template = controller.settings.fetch("default_#{type}".to_sym)
      template = Utils.lookup_template_with_default(base_dir, path, default_template)
      Application.inform_dev(
        "Using #{type} #{template.inspect} for #{controller.class}.#{controller.racket.action}."
      )
      store[path] = template
    end
  end
end
