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

    attr_reader :layouts_by_path
    attr_reader :views_by_path

    def initialize(layout_base_dir, view_base_dir)
      @layout_base_dir = layout_base_dir
      @view_base_dir = view_base_dir
      @layouts_by_path = {}
      @views_by_path = {}
    end

    # Renders a controller based on the request path and the variables set in the
    # controller instance.
    #
    # @param [Controller] controller
    # @return [Hash]
    def render(controller)
      template_path = get_template_path(controller)
      view = get_view(template_path, controller)
      if view
        output = Tilt.new(view).render(controller)
        layout = get_layout(template_path, controller)
        output = Tilt.new(layout).render(controller) { output } if layout
      else
        output = controller.racket.action_result
      end
      controller.response.write(output)
      controller.response.finish
    end

    private

    def get_template_path(controller)
      template_path = [Application.get_route(controller.class), controller.racket.action].join('/')
      template_path = template_path[1..-1] if template_path.start_with?('//')
      template_path
    end

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
      proc_args =
        case proc.arity
        when 0 then []
        when 1 then [controller.racket.action]
        when 2 then [controller.racket.action, controller.racket.params]
        when 3 then [controller.racket.action, controller.racket.params, controller.request]
        else fail ArgumentError, 'Template proc must take 0-3 parameters.'
        end
      proc.call(*proc_args).to_s
    end

    # Tries to locate a layout matching +path+ in the file system and returns the path if a
    # matching file is found. If no matching file is found, +nil+ is returned. The result is cached,
    # meaning that the filesystem lookup for a specific path will only happen once.
    #
    # @param [String] path
    # @param [Racket::Controller] controller
    # @return [String|nil]
    def get_layout(path, controller)
      unless @layouts_by_path.key?(path)
        layout = lookup_template(@layout_base_dir, path)
        layout =
          lookup_default_template(
            @layout_base_dir, File.dirname(path), controller.controller_option(:default_layout)
          ) unless layout
        Application.inform_dev(
          "Using layout #{layout.inspect} for #{controller.class}.#{controller.racket.action}."
        )
        @layouts_by_path[path] = layout
      end
      layout = @layouts_by_path[path]
      if layout.is_a?(Proc)
        layout =
          lookup_template(
            @layout_base_dir,
            [File.dirname(path), call_template_proc(layout, controller)].join('/')
          )
      end
      layout
    end

    # Tries to locate a view matching +path+ in the file system and returns the path if a
    # matching file is found. If no matching file is found, +nil+ is returned. The result is cached,
    # meaning that the filesystem lookup for a specific path will only happen once.
    #
    # @param [String] path
    # @param [Racket::Controller] controller
    # @return [String|nil]
    def get_view(path, controller)
      unless @views_by_path.key?(path)
        view = lookup_template(@view_base_dir, path)
        view =
          lookup_default_template(
            @view_base_dir, File.dirname(path), controller.controller_option(:default_view)
          ) unless view
        Application.inform_dev(
          "Using view #{view.inspect} for #{controller.class}.#{controller.racket.action}."
        )
        @views_by_path[path] = view
      end
      view = @views_by_path[path]
      if view.is_a?(Proc)
        view =
          lookup_template(
            @view_base_dir,
            [File.dirname(path), call_template_proc(view, controller)].join('/')
          )
      end
      view
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
  end
end
