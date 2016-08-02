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

require 'racket/registry'

module Racket
  module Utils
    module Application
      # Class for easily building a Racket::Registry.
      class RegistryBuilder
        attr_reader :registry

        def initialize(settings = {})
          @registry = Racket::Registry.new
          {
            action_cache: [Racket::Utils::Routing::ActionCache, {}],
            application_settings: [Racket::Settings::Application, settings],
            application_logger: [Racket::Utils::Application::Logger, {}],
            controller_context: [nil, {}],
            handler_stack: [Racket::Utils::Application::HandlerStack, {}],
            helper_cache: [Racket::Utils::Helpers::HelperCache, {}],
            layout_cache: [Racket::Utils::Views::TemplateCache, {}],
            layout_resolver: [Racket::Utils::Views::TemplateResolver, { type: :layout }],
            router: [Racket::Router, {}],
            static_server: [nil, {}],
            template_locator: [Racket::Utils::Views::TemplateLocator, {}],
            template_renderer: [Racket::Utils::Views::Renderer, {}],
            view_cache: [Racket::Utils::Views::TemplateCache, {}],
            view_manager: [Racket::ViewManager, {}],
            view_resolver: [Racket::Utils::Views::TemplateResolver, { type: :view }],
            utils: [Racket::Utils::ToolBelt, { root_dir: settings.fetch(:root_dir, Dir.pwd) }]
          }.each_pair do |key, val|
            klass, options = val
            if klass
              # Service available
              @registry.singleton(key, klass.send(:service, options))
            else
              # No service, we should handle it ourselves
              @registry.singleton(key, send(key))
            end
          end
        end

        private

        def controller_context
          lambda do |reg|
            Module.new do
              define_singleton_method(:application_settings) { reg.application_settings }
              define_singleton_method(:helper_cache) { reg.helper_cache }
              define_singleton_method(:logger) { reg.application_logger }
              define_singleton_method(:get_route) do |klass, action, params|
                reg.router.get_route(klass, action, params)
              end
              define_singleton_method(:utils) { reg.utils }
              define_singleton_method(:view_manager) { reg.view_manager }
            end
          end
        end

        def static_server
          lambda do |reg|
            logger = reg.application_logger
            if (public_dir = reg.application_settings.public_dir) &&
               Racket::Utils::FileSystem.dir_readable?(Pathname.new(public_dir))
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
      end
    end
  end
end
