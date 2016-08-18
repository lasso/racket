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

require_relative 'stateless_services.rb'

module Racket
  module Utils
    module Application
      # Class for easily building a Racket::Registry.
      class RegistryBuilder
        attr_reader :registry

        def initialize(settings = {})
          @settings = settings
          @registry = Racket::Registry.singleton_map(service_map)
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

        def service_map
          {
            application_settings: Racket::Settings::Application.service(@settings),
            controller_context: controller_context,
            static_server: static_server,
            utils: Racket::Utils::ToolBelt.service(root_dir: @settings.fetch(:root_dir, Dir.pwd))
          }.merge!(StatelessServices.services)
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
