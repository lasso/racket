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

require 'logger'

require_relative 'base.rb'

module Racket
  module Settings
    # Class for storing application settings.
    class Application < Base
      setting(:default_action, :index)
      setting(:default_content_type, 'text/html')
      setting(:default_controller_helpers, [:routing, :view])
      setting(:default_layout, nil)
      setting(:default_view, nil)
      setting(:logger, Logger.new($stdout))
      setting(:middleware, [])
      setting(:mode, :live)
      setting(
        :session_handler,
        [
          Rack::Session::Cookie,
          {
            key: 'racket.session',
            old_secret: SecureRandom.hex(16),
            secret: SecureRandom.hex(16)
          }
        ]
      )
      setting(:root_dir, nil) # Will be set automatically by constructor.

      def initialize(defaults = {})
        defaults[:root_dir] = Dir.pwd unless defaults.key?(:root_dir)
        super(defaults)
      end

      # Creates a directory setting with a default value.
      #
      # @param [Symbol] symbol
      # @param [String] directory
      # @return [nil]
      def self.directory_setting(symbol, directory)
        ivar = "@#{symbol}".to_sym
        define_method symbol do
          instance_variable_set(ivar, directory) unless instance_variables.include?(ivar)
          return nil unless (value = instance_variable_get(ivar))
          Utils.build_path(value)
        end
        attr_writer(symbol) && nil
      end

      directory_setting(:controller_dir, 'controllers')
      directory_setting(:helper_dir, 'helpers')
      directory_setting(:layout_dir, 'layouts')
      directory_setting(:public_dir, 'public')
      directory_setting(:view_dir, 'views')
    end
  end
end
