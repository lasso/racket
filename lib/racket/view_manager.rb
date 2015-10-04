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
      template_path = Utils::Views.get_template_path(controller)
      view = get_template(template_path, controller, :view)
      layout = view ? get_template(template_path, controller, :layout) : nil
      if view then output = Utils::Views.render_template(controller, view, layout)
      else output = controller.racket.action_result
      end
      controller.response.write(output)
      controller.response.finish
    end

    private

    # Returns a cached template. If the template has not been cached yet, this method will run a
    # lookup against the provided parameters.
    #
    # @param [String] path
    # @param [Racket::Controller] controller
    # @param [Symbol] type
    # @return [String|Proc|nil]
    def ensure_in_cache(path, controller, type)
      store = instance_variable_get("@#{type}_cache".to_sym)
      return store[path] if store.key?(path)
      store_in_cache(store, path, controller, type)
    end

    # Tries to locate a template matching +path+ in the file system and returns the path if a
    # matching file is found. If no matching file is found, +nil+ is returned. The result is cached,
    # meaning that the filesystem lookup for a specific path will only happen once.
    #
    # @param [String] path
    # @param [Racket::Controller] controller
    # @param [Symbol] type
    # @return [String|nil]
    def get_template(path, controller, type)
      template = ensure_in_cache(path, controller, type)
      # If template is a Proc, call it
      template =
        Utils::Views.lookup_template(
          instance_variable_get("@#{type}_base_dir".to_sym),
          [File.dirname(path), Utils::Views.call_template_proc(template, controller)].join('/')
        ) if template.is_a?(Proc)
      template
    end

    # Stores the location of a template (not its contents) in the cache.
    #
    # @param [Object] store Where to store the location
    # @param [String] path
    # @param [Racket::Controller] controller
    # @param [Symbol] type
    # @return [String|Proc|nil]
    def store_in_cache(store, path, controller, type)
      base_dir = instance_variable_get("@#{type}_base_dir".to_sym)
      default_template = controller.settings.fetch("default_#{type}".to_sym)
      template = Utils::Views.lookup_template(base_dir, path)
      template =
        Utils::Views.lookup_default_template(
          base_dir, File.dirname(path), default_template
        ) unless template
      Application.inform_dev(
        "Using #{type} #{template.inspect} for #{controller.class}.#{controller.racket.action}."
      )
      store[path] = template
    end
  end
end
