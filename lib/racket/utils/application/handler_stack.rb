# Racket - The noisy Rack MVC framework
# Copyright (C) 2015-2018  Lars Olsson <lasso@lassoweb.se>
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

require 'ostruct'

module Racket
  module Utils
    module Application
      # Class used for building a proper Rack application.
      class HandlerStack
        attr_reader :stack

        # Returns a service proc that can be used by the registry.
        #
        # @param  [Hash] _options (unused)
        # @return [Proc]
        def self.service(_options = {})
          lambda do |reg|
            settings = reg.application_settings
            options = service_options(reg, settings)
            new(options).stack
          end
        end

        def self.service_options(reg, settings)
          {
            default_content_type: settings.default_content_type,
            default_controller_helpers: settings.default_controller_helpers,
            dev_mode: settings.mode == :dev, logger: reg.application_logger,
            middleware: settings.middleware, plugins: settings.plugins,
            router: reg.router, session_handler: settings.session_handler,
            static_server: reg.static_server, utils: reg.utils,
            warmup_urls: settings.warmup_urls
          }
        end

        private_class_method :service_options

        def initialize(options)
          @stack = Rack::Builder.new
          @options = OpenStruct.new(options)
          build
        end

        private

        # Builds a Rack application representing Racket.
        #
        # @return [Proc]
        def build
          init_plugins
          add_warmup_hook
          add_middleware(@options.middleware)
          @stack.run(application_proc)
        end

        # Add middleware to the builder.
        def add_middleware(middleware)
          expand_middleware_list(middleware)
          middleware.each do |ware|
            klass, opts = ware
            @options.logger.inform_dev("Loading middleware #{klass} with settings #{opts.inspect}.")
            @stack.use(*ware)
          end
        end

        # Add a list of urls to visit on startup
        def add_warmup_hook
          warmup_urls = @options.warmup_urls
          return if warmup_urls.empty?
          @stack.warmup do |app|
            client = Rack::MockRequest.new(app)
            visit_warmup_urls(client, warmup_urls)
          end
        end

        # Returns a lambda that represenents that application flow.
        def application_proc
          if (static_server = @options.static_server)
            application_proc_with_static_server(static_server)
          else
            application_proc_without_static_server
          end
        end

        def application_proc_with_static_server(static_server)
          router = @options.router
          lambda do |env|
            static_result = static_server.call(env)
            return static_result if static_result && static_result.first < 400
            router.route(env)
          end
        end

        def application_proc_without_static_server
          router = @options.router
          ->(env) { router.route(env) }
        end

        # Expands middleware list based on application settings.
        def expand_middleware_list(middleware)
          session_handler = @options.session_handler
          default_content_type = @options.default_content_type
          middleware.unshift(session_handler) if session_handler
          middleware.unshift([Rack::ContentType, default_content_type]) if
            default_content_type
          middleware.unshift([Rack::ShowExceptions]) if @options.dev_mode
        end

        # Returns an instance of a specific plugin.
        #
        # @param [Symbol] plugin
        # @param [Hash|nil] settings
        # @return [Object] An instance of the requested plugin class
        def get_plugin_instance(plugin, settings)
          @options.utils.safe_require("racket/plugins/#{plugin}.rb")
          # TODO: Allow custom plugins dir as well
          klass =
            Racket::Plugins.const_get(plugin.to_s.split('_').collect(&:capitalize).join.to_sym)
          klass.new(settings)
        end

        # Initializes plugins.
        def init_plugins
          @options.plugins.each do |plugin_info|
            plugin_instance = get_plugin_instance(*plugin_info)
            run_plugin_hooks(plugin_instance)
            # TODO: Store plugin instance somewhere in application settings
          end
        end

        # Runs plugin hooks.
        def run_plugin_hooks(plugin_obj)
          @options.middleware.concat(plugin_obj.middleware)
          @options.default_controller_helpers.concat(plugin_obj.default_controller_helpers)
        end

        # Visits a list of warmup URLs.
        def visit_warmup_urls(client, urls)
          urls.each do |url|
            @options.logger.inform_dev("Visiting warmup url #{url}.")
            client.get(url)
          end
        end
      end
    end
  end
end
