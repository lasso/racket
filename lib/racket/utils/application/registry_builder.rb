# Racket - The noisy Rack MVC framework
# Copyright (C) 2015-2017  Lars Olsson <lasso@lassoweb.se>
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

        # Sets up a static server with the specified directory and logger.
        #
        # @param [Pathname|nil] static_dir
        # @param [Logger] logger
        # @return [Proc|nil]
        def self.static_server(static_dir, logger)
          return nil unless static_dir_valid?(static_dir, logger)
          logger.inform_dev("Setting up static server to serve files from #{static_dir}.")
          handler = Rack::File.new(static_dir)
          ->(env) { handler.call(env) }
        end

        def self.static_dir_valid?(static_dir, logger)
          logger.inform_dev('Static server disabled.') unless static_dir
          static_dir
        end

        private_class_method :static_dir_valid?

        private

        def controller_context
          lambda do |reg|
            define_context_singleton_methods(reg)
          end
        end

        def define_context_singleton_methods(reg)
          context = {
            application_settings: :application_settings,
            helper_cache: :helper_cache,
            logger: :application_logger,
            utils: :utils,
            view_manager: :view_manager
          }
          Module.new do
            context.each_pair do |key, val|
              define_singleton_method(key) { reg.send(val) }
            end
            define_singleton_method(:get_route) do |klass, action, params|
              reg.router.get_route(klass, action, params)
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
          klass = self.class
          lambda do |reg|
            klass.static_server(
              Racket::Utils::FileSystem.dir_or_nil(reg.application_settings.public_dir),
              reg.application_logger
            )
          end
        end
      end
    end
  end
end
