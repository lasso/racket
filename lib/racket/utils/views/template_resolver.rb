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
      # Class used for resolving template paths.
      class TemplateResolver
        def initialize(utils)
          @utils = utils
        end

        def calculate_path(path, template_params)
          type, controller, base_dir = template_params.to_a
          default_template = controller.settings.fetch("default_#{type}".to_sym)
          template =
            lookup_template_with_default(
              @utils.fs_path(base_dir, path), default_template
            )
          ::Racket::Application.inform_dev(
            "Using #{type} #{template.inspect} for #{controller.class}.#{controller.racket.action}."
          )
          template
        end

        # Returns the "url path" that should be used when searching for templates.
        #
        # @param [Racket::Controller] controller
        # @return [String]
        def get_template_path(controller)
          template_path =
            [::Racket::Application.get_route(controller.class), controller.racket.action].join('/')
          template_path = template_path[1..-1] if template_path.start_with?('//')
          template_path
        end

        def resolve_template(path, template, template_params)
          return template unless template.is_a?(Proc)
          _, controller, base_dir = template_params.to_a
          lookup_template(
            @utils.fs_path(
              @utils.fs_path(base_dir, path).dirname,
              call_template_proc(template, controller)
            )
          )
        end

        private

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
        def call_template_proc(proc, controller)
          racket = controller.racket
          proc_args = [racket.action, racket.params, controller.request].slice(0...proc.arity)
          proc.call(*proc_args).to_s
        end

        # Locates a file in the filesystem matching an URL path. If there exists a matching file,
        # the path to it is returned. If there is no matching file, +nil+ is returned.
        # @param [Pathname] path
        # @return [Pathname|nil]
        def lookup_template(path)
          @utils.first_matching_path(*@utils.extract_dir_and_glob(path))
        end

        # Locates a file in the filesystem matching an URL path. If there exists a matching file,
        # the path to it is returned. If there is no matching file and +default_template+ is a
        # String or a Symbol, another lookup will be performed using +default_template+. If
        # +default_template+ is a Proc or nil, +default_template+ will be used as is instead.
        #
        # @param [Pathname] path
        # @param [String|Symbol|Proc|nil] default_template
        # @return [String|Proc|nil]
        def lookup_template_with_default(path, default_template)
          template = lookup_template(path)
          unless template
            if default_template.is_a?(String) || default_template.is_a?(Symbol)
              # Strings and symbols can be lookup up in the file system...
              template = lookup_template(Utils.fs_path(path.dirname, default_template))
            else
              # ...but not nils/procs!
              template = default_template
            end
          end
          template
        end
      end
    end
  end
end
