=begin
Racket - The noisy Rack MVC framework
Copyright (C) 2015  Lars Olsson <lasso@lassoweb.se>

This file is part of Racket.

Racket is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Racket is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with Racket.  If not, see <http://www.gnu.org/licenses/>.
=end

require 'tilt'

module Racket
  # Handles rendering in Racket applications.
  class ViewCache

    def initialize(layout_base_dir, template_base_dir)
      @layout_base_dir = layout_base_dir
      @template_base_dir = template_base_dir
      @layouts_by_path = {}
      @templates_by_path = {}
    end

    # Renders a controller based on the request path and the variables set in the
    # controller instance.
    #
    # @param [Controller] controller
    # @return [Hash]
    def render(controller)
      template =
        find_template(controller.request.path, controller.controller_option(:default_view))
      if template
        output = Tilt.new(template).render(controller)
        layout =
          find_layout(controller.request.path, controller.controller_option(:default_layout))
        output = Tilt.new(layout).render(controller) { output } if layout
      else
        output = controller.racket.action_result
      end
      controller.response.write(output)
      controller.response.finish
    end

    private

    # Tries to locate a layout matching +url_path+ in the file system and returns the path if a
    # matching file is found. If no matching file is found, +nil+ is returned. The result is
    # cached, meaning that the filesystem lookup for a specific url_path will only happen once.
    #
    # @param [String] url_path
    # @param [String|nil] default_layout
    # @return [String|nil]
    def find_layout(url_path, default_layout)
      return @layouts_by_path[url_path] if @layouts_by_path.key?(url_path)
      @layouts_by_path[url_path] = find_matching_file(@layout_base_dir, url_path, default_layout)
    end

    # Tries to locate a template matching +url_path+ in the file system and returns the path if a
    # matching file is found. If no matching file is found, +nil+ is returned. The result is
    # cached, meaning that the filesystem lookup for a specific url_path will only happen once.
    #
    # @param [String] url_path
    # @param [String|nil] default_view
    # @return [String|nil]
    def find_template(url_path, default_view)
      return @templates_by_path[url_path] if @templates_by_path.key?(url_path)
      @templates_by_path[url_path] = find_matching_file(@template_base_dir, url_path, default_view)
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
            return File.join(file_path, files.first.to_s)
          end
          return nil # Neither default file or specified file found
        end
        File.join(file_path, files.first.to_s)
      end
    end

  end

end
