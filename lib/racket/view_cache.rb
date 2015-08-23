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
  class ViewCache
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
      template_path = [Application.get_route(controller.class), controller.racket.action].join('/')
      template_path = template_path[1..-1] if template_path.start_with?('//')
      default_view, cache_view = get_default_template(controller, :default_view)
      template = find_view(template_path, default_view, cache_view)
      if template
        output = Tilt.new(template).render(controller)
        default_layout, cache_layout = get_default_template(controller, :default_layout)
        layout = find_layout(template_path, default_layout, cache_layout)
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

    # Tries to locate a layout matching +url_path+ in the file system and returns the path if a
    # matching file is found. If no matching file is found, +nil+ is returned. If requested, the
    # result is cached, meaning that the filesystem lookup for a specific url_path will only happen
    # once.
    #
    # @param [String] url_path
    # @param [String|nil] default_layout
    # @param [true|false] cache_layout
    # @return [String|nil]
    def find_layout(url_path, default_layout, cache_layout)
      if cache_layout
        return @layouts_by_path[url_path] if @layouts_by_path.key?(url_path)
        @layouts_by_path[url_path] = find_matching_file(@layout_base_dir, url_path, default_layout)
      else
        find_matching_file(@layout_base_dir, url_path, default_layout)
      end
    end

    # Tries to locate a view matching +url_path+ in the file system and returns the path if a
    # matching file is found. If no matching file is found, +nil+ is returned. If requested, the
    # result is cached, meaning that the filesystem lookup for a specific url_path will only happen
    # once.
    #
    # @param [String] url_path
    # @param [String|nil] default_view
    # @param [true|false] cache_view
    # @return [String|nil]
    def find_view(url_path, default_view, cache_view)
      if cache_view
        return @views_by_path[url_path] if @views_by_path.key?(url_path)
        @views_by_path[url_path] = find_matching_file(@view_base_dir, url_path, default_view)
      else
        find_matching_file(@view_base_dir, url_path, default_view)
      end
    end

    # Locates a file in the filesystem matching an URL path. If there exists a matching file, the
    # path to it is returned. If there is no matching file, +nil+ is returned.
    #
    # @param [String] base_file_path
    # @param [String] url_path
    # @param [String|nil] default_file
    # @return [String|nil]
    def find_matching_file(base_file_path, url_path, default_file)
      file_path = File.join(base_file_path, url_path)
      action = File.basename(file_path)
      file_path = File.dirname(file_path)
      return nil unless Utils.dir_readable?(file_path)
      Dir.chdir(file_path) do
        files = Pathname.glob("#{action}.*")
        if files.empty?
          if default_file
            files = Pathname.glob(default_file)
            return nil if files.empty? # No default file found
            final_path = File.join(file_path, files.first.to_s)
            return Utils.file_readable?(final_path) ? final_path : nil
          end
          return nil # Neither default file or specified file found
        end
        final_path = File.join(file_path, files.first.to_s)
        return Utils.file_readable?(final_path) ? final_path : nil
      end
    end

    # Gets the default layout/view template for the current controller action.
    #
    # @param [Racket::Controller] controller
    # @param [Symbol] key
    # @return [String|nil]
    def get_default_template(controller, key)
      default = controller.controller_option(key)
       # If default is nil we can cache it.
      return [nil, true] if default.nil?
      # If default is a proc we should not cache it.
      return [call_template_proc(default, controller), false] if default.is_a?(Proc)
      # Default is a string so we can cache it.
      [default.to_s, true]
    end
  end
end
