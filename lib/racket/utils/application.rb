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
  # Collects utilities needed by different objects in Racket.
  module Utils
    # Utility functions for filesystem.
    module Application
      # Class used for building a proper Rack application.
      class ApplicationBuilder
        def initialize(application)
          @application = application
          @builder = Rack::Builder.new
          @settings = @application.settings
          @middleware = @settings.middleware
        end

        # Builds a Rack application representing Racket.
        #
        # @return [Proc]
        def build
          init_plugins
          add_warmup_hook
          expand_middleware_list
          add_middleware
          @builder.run(application_proc)
          @builder
        end

        private

        # Add middleware to the builder.
        def add_middleware
          @middleware.each do |ware|
            klass, opts = ware
            @application.inform_dev("Loading middleware #{klass} with settings #{opts.inspect}.")
            @builder.use(*ware)
          end
        end

        # Add a list of urls to visit on startup
        def add_warmup_hook
          @builder.warmup do |app|
            warmup_urls = Racket::Application.settings.warmup_urls
            unless warmup_urls.empty?
              client = Rack::MockRequest.new(app)
              warmup_urls.each do |url|
                @application.inform_dev("Visiting warmup url #{url}.")
                client.get(url)
              end
            end
          end
        end

        # Returns a lambda that represenents that application flow.
        def application_proc
          application = @application
          lambda do |env|
            static_result = application.serve_static_file(env)
            return static_result if static_result && static_result.first < 400
            application.router.route(env)
          end
        end

        # Expands middleware list based on application settings.
        def expand_middleware_list
          session_handler = @settings.session_handler
          default_content_type = @settings.default_content_type
          @middleware.unshift(session_handler) if session_handler
          @middleware.unshift([Rack::ContentType, default_content_type]) if default_content_type
          @middleware.unshift([Rack::ShowExceptions]) if @application.dev_mode?
        end

        # Initializes plugins.
        def init_plugins
          @settings.plugins.each do |plugin_info|
            plugin_instance = self.class.get_plugin_instance(*plugin_info)
            run_plugin_hooks(plugin_instance)
            # TODO: Store plugin instance somewhere in application settings
          end
        end

        # Runs plugin hooks.
        def run_plugin_hooks(plugin_obj)
          @middleware.concat(plugin_obj.middleware)
          @settings.default_controller_helpers.concat(plugin_obj.default_controller_helpers)
        end

        # Returns an instance of a specific plugin.
        #
        # @param [Symbol] plugin
        # @param [Hash|nil] settings
        # @return [Object] An instance of the requested plugin class
        def self.get_plugin_instance(plugin, settings)
          Utils.safe_require("racket/plugins/#{plugin}.rb")
          # TODO: Allow custom plugins dir as well
          klass =
            Racket::Plugins.const_get(plugin.to_s.split('_').collect(&:capitalize).join.to_sym)
          klass.new(settings)
        end
      end

      # Builds and returns a Rack::Builder using the provided Racket::Application
      #
      # @param [Racket::Application] application
      # @return [Rack::Builder]
      def self.build_application(application)
        ApplicationBuilder.new(application).build
      end
    end
  end
end
