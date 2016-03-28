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
          build_registry(settings)
        end

        private

        def build_registry(settings)
          @registry.register(:action_cache) do |c|
            Racket::Utils::Routing::ActionCache.new(c.resolve(:application_logger))
          end

          @registry.register(:application) do
            Racket::Application.new
          end

          @registry.register(:application_logger) do |c|
            Racket::Utils::Application::Logger.new(
              c.resolve(:application_settings).logger, c.resolve(:application_settings).mode
            )
          end

          @registry.register(:application_settings) do |c|
            Racket::Settings::Application.new(c.resolve(:utils), settings)
          end

          @registry.register(:layout_cache) do
            Racket::Utils::Views::TemplateCache.new
          end

          @registry.register(:router) do |c|
            Racket::Router.new(
              c.resolve(:action_cache),
              c.resolve(:application_logger),
              c.resolve(:utils)
            )
          end

          @registry.register(:template_locator) do |c|
            settings = c.resolve(:application_settings)
            Racket::Utils::Views::TemplateLocator.new(
              layout_base_dir: settings.layout_dir,
              layout_cache: c.resolve(:layout_cache),
              view_base_dir: settings.view_dir,
              view_cache: c.resolve(:view_cache)
            )
          end

          @registry.register(:template_renderer) do
            Utils::Views::ViewRenderer
          end

          @registry.register(:view_cache) do
            Racket::Utils::Views::TemplateCache.new
          end

          @registry.register(:view_manager) do |c|
            Racket::ViewManager.new(
              c.resolve(:template_locator), c.resolve(:template_renderer)
            )
          end

          @registry.register(:utils) do
            Racket::Utils::ToolBelt.new
          end

          nil
        end
      end
    end
  end
end
