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

require 'racket/registry'

module Racket
  module Utils
    module Application
      # Class for easily building a Racket::Registry.
      class RegistryBuilder
        attr_reader :registry

        def initialize(settings = {})
          @registry = Racket::Registry.new
          @registry.singleton(:application_settings) do |reg|
            Racket::Settings::Application.new(reg.utils, settings)
          end
          private_methods(false).grep(/^register_/).each { |meth| send(meth) }
        end

        private

        def register_action_cache
          @registry.singleton(:action_cache) do |reg|
            Racket::Utils::Routing::ActionCache.new(reg.application_logger)
          end
        end

        def register_application_logger
          @registry.singleton(:application_logger) do |reg|
            settings = reg.application_settings
            Racket::Utils::Application::Logger.new(settings.logger, settings.mode)
          end
        end

        def register_controller_context
          @registry.singleton(:controller_context) do |reg|
            Module.new do
              define_singleton_method(:application_settings) { reg.application_settings }
              define_singleton_method(:helper_cache) { reg.helper_cache }
              define_singleton_method(:logger) { reg.application_logger }
              define_singleton_method(:utils) { reg.utils }
            end
          end
        end

        def register_handler_stack
          @registry.singleton(:handler_stack) do |reg|
            settings = reg.application_settings

            options = {
              default_content_type:       settings.default_content_type,
              default_controller_helpers: settings.default_controller_helpers,
              dev_mode:                   settings.mode == :dev,
              logger:                     reg.application_logger,
              middleware:                 settings.middleware,
              plugins:                    settings.plugins,
              router:                     reg.router,
              session_handler:            settings.session_handler,
              static_server:              reg.static_server,
              utils:                      reg.utils,
              warmup_urls:                settings.warmup_urls
            }

            Racket::Utils::Application::Builder.new(options).build
          end
        end

        def register_helper_cache
          @registry.singleton(:helper_cache) do |reg|
            Racket::Utils::Helpers::HelperCache.new(
              reg.application_settings.helper_dir,
              reg.application_logger,
              reg.utils
            )
          end
        end

        def register_layout_cache
          @registry.singleton(:layout_cache) do
            Racket::Utils::Views::TemplateCache.new({})
          end
        end

        def register_layout_resolver
          @registry.singleton(:layout_resolver) do |reg|
            Racket::Utils::Views::TemplateResolver.new(
              base_dir: reg.application_settings.layout_dir,
              logger: reg.application_logger,
              type: :layout,
              utils: reg.utils
            )
          end
        end

        def register_router
          @registry.singleton(:router) do |reg|
            Racket::Router.new(
              action_cache: reg.action_cache,
              dev_mode: reg.application_settings.mode == :dev,
              logger: reg.application_logger,
              utils: reg.utils
            )
          end
        end

        def register_static_server
          @registry.singleton(:static_server) do |reg|
            logger = reg.application_logger
            if (public_dir = reg.application_settings.public_dir) &&
               reg.utils.dir_readable?(Pathname.new(public_dir))
              logger.inform_dev(
                "Setting up static server to serve files from #{public_dir}."
              )
              handler = Rack::File.new(public_dir)
              ->(env) { handler.call(env) }
            else
              logger.inform_dev('Static server disabled.') && nil
            end
          end
        end

        def register_template_locator
          @registry.singleton(:template_locator) do |reg|
            Racket::Utils::Views::TemplateLocator.new(
              layout_cache: reg.layout_cache,
              layout_resolver: reg.layout_resolver,
              view_cache: reg.view_cache,
              view_resolver: reg.view_resolver
            )
          end
        end

        def register_template_renderer
          @registry.singleton(:template_renderer) do
            Racket::Utils::Views::Renderer
          end
        end

        def register_view_cache
          @registry.singleton(:view_cache) do
            Racket::Utils::Views::TemplateCache.new({})
          end
        end

        def register_view_manager
          # No singleton - if application is reloaded, we want a new view manager
          @registry.register(:view_manager) do |reg|
            Racket::ViewManager.new(
              reg.template_locator, reg.template_renderer
            )
          end
        end

        def register_view_resolver
          @registry.singleton(:view_resolver) do |reg|
            Racket::Utils::Views::TemplateResolver.new(
              base_dir: reg.application_settings.view_dir,
              logger: reg.application_logger,
              type: :view,
              utils: reg.utils
            )
          end
        end

        def register_utils
          @registry.singleton(:utils) do
            Racket::Utils::ToolBelt.new
          end
        end
      end
    end
  end
end
