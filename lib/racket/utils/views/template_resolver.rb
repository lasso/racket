# Racket - The noisy Rack MVC framework
# Copyright (C) 2015-2016  Lars Olsson <lasso@lassoweb.se>
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
        # Alias for Racket::Utils::FileSystem module.
        FSM = Racket::Utils::FileSystem

        # Returns a service proc that can be used by the registry.
        #
        # @param  [Hash] options
        # @return [Proc]
        def self.service(options = {})
          type = options[:type]
          lambda do |reg|
            new(
              base_dir: reg.application_settings.send("#{type}_dir"),
              logger: reg.application_logger,
              type: type,
              utils: reg.utils
            )
          end
        end

        def initialize(options)
          required_options =
            {
              base_dir: 'Base dir is missing.', logger: 'Logger is missing.',
              type: 'Type is missing.', utils: 'Utils is missing.'
            }
          ::Racket::Utils::Options.validate_options(required_options, options)
          required_options.each_key do |key|
            instance_variable_set("@#{key}".to_sym, options[key])
          end
        end

        # Returns the template object representing the specified path/controller combination.
        #
        # @param [String] path
        # @param [Racket::Controller] controller
        # @return [Pathname|Proc|nil]
        def get_template_object(path, controller)
          default_template = controller.settings.fetch("default_#{@type}".to_sym)
          template =
            lookup_template_with_default(
              FSM.fs_path(@base_dir, path), default_template
            )
          @logger.inform_dev(
            "Using #{@type} #{template.inspect} for #{controller.class}." \
            "#{controller.racket.action}."
          )
          template
        end

        # Returns the "resolved" path for the given parameters. This is either a pathname or nil.
        #
        # @param [String] path
        # @param [Proc|String|nil] template
        # @param [Racket::Controller] controller
        # @return [pathname|nil]
        def resolve_template(path, template, controller)
          return template unless template.is_a?(Proc)
          lookup_template(
            FSM.fs_path(
              FSM.fs_path(@base_dir, path).dirname,
              self.class.call_template_proc(template, controller)
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
            [controller.class.get_route, controller.racket.action].join('/')
          template_path = template_path[1..-1] if template_path.start_with?('//')
          template_path
        end

        private

        # Extracts the correct directory and glob for a given base path/path combination.
        #
        # @param [Pathname] path
        # @return [Array]
        def extract_dir_and_glob(path)
          basename = path.basename
          [
            path.dirname,
            path.extname.empty? ? Pathname.new("#{basename}.*") : basename
          ]
        end

        # Locates a file in the filesystem matching an URL path. If there exists a matching file,
        # the path to it is returned. If there is no matching file, +nil+ is returned.
        # @param [Pathname] path
        # @return [Pathname|nil]
        def lookup_template(path)
          FSM.first_matching_path(*extract_dir_and_glob(path))
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
          # Return template if it can be found in the file system
          template = lookup_template(path)
          return template if template
          # No template found for path. Try the default template instead.
          # If default template is a string or a symbol, look it up in the file system
          return lookup_template(FSM.fs_path(path.dirname, default_template)) if
            default_template.is_a?(String) || default_template.is_a?(Symbol)
          # If default template is a proc or nil, just return it
          default_template
        end
      end
    end
  end
end
