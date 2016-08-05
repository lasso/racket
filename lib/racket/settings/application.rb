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

require 'logger'
require 'racket/registry'

require_relative 'base.rb'

module Racket
  module Settings
    # Class for storing application settings.
    class Application < Base
      @defaults =
        Racket::Registry.with_map(
          default_action: -> { :index },
          default_content_type: -> { 'text/html' },
          default_controller_helpers: -> { [:routing, :view] },
          default_layout: -> { nil },
          default_view: -> { nil },
          logger: -> { Logger.new($stdout) },
          middleware: -> { [] },
          mode: -> { :live },
          plugins: -> { [] },
          session_handler:
            lambda do
              [
                Rack::Session::Cookie,
                {
                  key: 'racket.session',
                  old_secret: SecureRandom.hex(16),
                  secret: SecureRandom.hex(16)
                }
              ]
            end,
          root_dir: -> { Dir.pwd },
          template_settings:
            lambda do
              {
                common: {},
                layout: {},
                view: {}
              }
            end,
          warmup_urls: -> { Set.new }
        )

      setting(:default_action)
      setting(:default_content_type)
      setting(:default_controller_helpers)
      setting(:default_layout)
      setting(:default_view)
      setting(:logger)
      setting(:middleware)
      setting(:mode)
      setting(:plugins)
      setting(:session_handler)
      setting(:root_dir)
      setting(:template_settings)
      setting(:warmup_urls)

      # Returns a service proc that can be used by the registry.
      #
      # @param  [Hash] options
      # @return [Proc]
      def self.service(options = {})
        ->(reg) { new(reg.utils, options) }
      end

      def initialize(utils, defaults = {})
        @utils = utils
        super(defaults)
      end

      # Creates a directory setting with a default value.
      #
      # @param [Symbol] symbol
      # @param [String] directory
      # @return [nil]
      def self.directory_setting(symbol, directory)
        define_directory_method(symbol, "@#{symbol}".to_sym, directory)
        attr_writer(symbol) && nil
      end

      def self.define_directory_method(symbol, ivar, directory)
        define_method symbol do
          instance_variable_set(ivar, directory) unless instance_variables.include?(ivar)
          return nil unless (value = instance_variable_get(ivar))
          @utils.build_path(value)
        end
      end

      directory_setting(:controller_dir, 'controllers')
      directory_setting(:helper_dir, 'helpers')
      directory_setting(:layout_dir, 'layouts')
      directory_setting(:public_dir, 'public')
      directory_setting(:view_dir, 'views')

      private_class_method :define_directory_method
    end
  end
end
