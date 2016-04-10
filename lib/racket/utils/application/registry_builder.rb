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

require 'ioc'

module Racket
  module Utils
    module Application
      # Class for easily building an IOC::Container.
      class RegistryBuilder
        attr_reader :registry

        def initialize(settings = {})
          @registry = IOC::Container.new
          register_action_cache
          register_application_logger
          register_application_settings(settings)
          register_layout_cache
          register_layout_resolver
          register_router
          register_template_locator
          register_template_renderer
          register_view_cache
          register_view_manager
          register_view_resolver
          register_utils
        end

        private

        def register_action_cache
          @registry.register(:action_cache) do |reg|
            Racket::Utils::Routing::ActionCache.new(reg.resolve(:application_logger))
          end
        end

        def register_application_logger
          @registry.register(:application_logger) do |reg|
            settings = reg.resolve(:application_settings)
            Racket::Utils::Application::Logger.new(settings.logger, settings.mode)
          end
        end

        def register_application_settings(settings)
          @registry.register(:application_settings) do |reg|
            Racket::Settings::Application.new(reg.resolve(:utils), settings)
          end
        end

        def register_layout_cache
          @registry.register(:layout_cache) do
            Racket::Utils::Views::TemplateCache.new({})
          end
        end

        def register_layout_resolver
          @registry.register(:layout_resolver) do |reg|
            Racket::Utils::Views::TemplateResolver.new(
              base_dir: reg.resolve(:application_settings).layout_dir,
              logger: reg.resolve(:application_logger),
              type: :layout,
              utils: reg.resolve(:utils)
            )
          end
        end

        def register_router
          @registry.register(:router) do |reg|
            Racket::Router.new(
              reg.resolve(:action_cache),
              reg.resolve(:application_logger),
              reg.resolve(:utils)
            )
          end
        end

        def register_template_locator
          @registry.register(:template_locator) do |reg|
            Racket::Utils::Views::TemplateLocator.new(
              layout_cache: reg.resolve(:layout_cache),
              layout_resolver: reg.resolve(:layout_resolver),
              view_cache: reg.resolve(:view_cache),
              view_resolver: reg.resolve(:view_resolver)
            )
          end
        end

        def register_template_renderer
          @registry.register(:template_renderer) do
            Racket::Utils::Views::Renderer
          end
        end

        def register_view_cache
          @registry.register(:view_cache) do
            Racket::Utils::Views::TemplateCache.new({})
          end
        end

        def register_view_manager
          @registry.register(:view_manager) do |reg|
            Racket::ViewManager.new(
              reg.resolve(:template_locator), reg.resolve(:template_renderer)
            )
          end
        end

        def register_view_resolver
          @registry.register(:view_resolver) do |reg|
            Racket::Utils::Views::TemplateResolver.new(
              base_dir: reg.resolve(:application_settings).view_dir,
              logger: reg.resolve(:application_logger),
              type: :view,
              utils: reg.resolve(:utils)
            )
          end
        end

        def register_utils
          @registry.register(:utils) do
            Racket::Utils::ToolBelt.new
          end
        end
      end
    end
  end
end
