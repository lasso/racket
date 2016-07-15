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
          register_action_cache
          register_application_logger
          register_application_settings(settings)
          register_layout_cache
          register_layout_resolver
          register_router
          register_static_server
          register_template_locator
          register_template_renderer
          register_view_cache
          register_view_manager
          register_view_resolver
          register_utils
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

        def register_application_settings(settings)
          @registry.singleton(:application_settings) do |reg|
            Racket::Settings::Application.new(reg.utils, settings)
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
              reg.action_cache,
              reg.application_logger,
              reg.utils
            )
          end
        end

        def register_static_server
          @registry.singleton(:static_server) do |reg|
            if (public_dir = reg.application_settings.public_dir) &&
               reg.utils.dir_readable?(Pathname.new(public_dir))
              reg.application_logger.inform_dev(
                "Setting up static server to serve files from #{public_dir}."
              )
              handler = Rack::File.new(public_dir)
              ->(env) { handler.call(env) }
            else
              ->(_env) { nil }
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
