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
      template_path = get_template_path(controller)
      view = get_template(template_path, controller, :view)
      if view
        output = Tilt.new(view).render(controller)
        layout = get_template(template_path, controller, :layout)
        output = Tilt.new(layout).render(controller) { output } if layout
      else
        output = controller.racket.action_result
      end
      controller.response.write(output)
      controller.response.finish
    end

    private

    # Calls a template proc. Depending on how many parameters the template proc takes, different
    # types of information will be passed to the proc.
    # If the proc takes zero parameters, no information will be passed.
    # If the proc takes one parameter, it will contain the current action.
    # If the proc takes two parameters, they will contain the current action and the current params.
    # If the proc takes three parameters, they will contain the current action, the current params
    #  and the current request.
    #
    # @param [Proc] proc
    # @param [Racket::Controller] controller
    # @return [String]
    def call_template_proc(proc, controller)
      possible_proc_args = [controller.racket.action, controller.racket.params, controller.request]
      proc_args = []
      1.upto(proc.arity) { proc_args.push(possible_proc_args.shift) }
      proc.call(*proc_args).to_s
    end

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
        lookup_template(
          instance_variable_get("@#{type}_base_dir".to_sym),
          [File.dirname(path), call_template_proc(template, controller)].join('/')
        ) if template.is_a?(Proc)
      template
    end

    # Returns the "url path" that should be used when searching for templates.
    #
    # @param [Racket::Controller] controller
    # @return [String]
    def get_template_path(controller)
      template_path = [Application.get_route(controller.class), controller.racket.action].join('/')
      template_path = template_path[1..-1] if template_path.start_with?('//')
      template_path
    end

    def lookup_default_template(base_path, path, default)
      return lookup_template(base_path, File.join(path, default.to_s)) if
        default.is_a?(String) || default.is_a?(Symbol)
      default
    end

    # Locates a file in the filesystem matching an URL path. If there exists a matching file, the
    # path to it is returned. If there is no matching file, +nil+ is returned.
    #
    # @param [String] base_path
    # @param [String] path
    # @return [String|nil]
    def lookup_template(base_path, path)
      file_path = File.join(base_path, path)
      action = File.basename(file_path)
      file_path = File.dirname(file_path)
      return nil unless Utils.dir_readable?(file_path)
      matcher = File.extname(action).empty? ? "#{action}.*" : action
      Dir.chdir(file_path) do
        files = Pathname.glob(matcher)
        return nil if files.empty?
        final_path = File.join(file_path, files.first.to_s)
        Utils.file_readable?(final_path) ? final_path : nil
      end
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
      default_template = controller.controller_setting("default_#{type}".to_sym)
      template = lookup_template(base_dir, path)
      template =
        lookup_default_template(base_dir, File.dirname(path), default_template) unless template
      Application.inform_dev(
        "Using #{type} #{template.inspect} for #{controller.class}.#{controller.racket.action}."
      )
      store[path] = template
    end
  end
end
