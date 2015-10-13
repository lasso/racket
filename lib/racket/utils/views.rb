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
      # Calls a template proc. Depending on how many parameters the template proc takes, different
      # types of information will be passed to the proc.
      # If the proc takes zero parameters, no information will be passed.
      # If the proc takes one parameter, it will contain the current action.
      # If the proc takes two parameters, they will contain the current action and the current
      #   params.
      # If the proc takes three parameters, they will contain the current action, the current params
      #  and the current request.
      #
      # @param [Proc] proc
      # @param [Racket::Controller] controller
      # @return [String]
      def self.call_template_proc(proc, controller)
        possible_proc_args =
          [controller.racket.action, controller.racket.params, controller.request]
        proc_args = []
        1.upto(proc.arity) { proc_args.push(possible_proc_args.shift) }
        proc.call(*proc_args).to_s
      end

      # Returns the "url path" that should be used when searching for templates.
      #
      # @param [Racket::Controller] controller
      # @return [String]
      def self.get_template_path(controller)
        template_path =
          [Application.get_route(controller.class), controller.racket.action].join('/')
        template_path = template_path[1..-1] if template_path.start_with?('//')
        template_path
      end

      # Locates a file in the filesystem matching an URL path. If there exists a matching file, the
      # path to it is returned. If there is no matching file, +nil+ is returned.
      # @param [Pathname] path
      # @return [Pathname|nil]
      def self.lookup_template(path)
        Utils.first_matching_path(*Utils.extract_dir_and_glob(path))
      end

      # Locates a file in the filesystem matching an URL path. If there exists a matching file, the
      # path to it is returned. If there is no matching file and +default_template+ is a String or
      # a Symbol, another lookup will be performed using +default_template+. If +default_template+
      # is a Proc or nil, +default_template+ will be used as is instead.
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
    end
  end
end
