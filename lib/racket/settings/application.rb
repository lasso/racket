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
      attr_reader :root_dir

      setting_with_default(:default_action, :index)
      setting_with_default(:default_content_type, 'text/html')
      setting_with_default(:default_controller_helpers, [:routing, :view])
      setting_with_default(:default_layout, nil)
      setting_with_default(:default_view, nil)
      setting_with_default(:logger, Logger.new($stdout))
      setting_with_default(:middleware, [])
      setting_with_default(:mode, :live)
      setting_with_default(
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

      def initialize(defaults = {})
        @root_dir = Utils.build_path(Dir.pwd)
        defaults.reject! { |key| key == :root_dir }
        super(defaults)
      end

      # Created a directory setting with a default value
      def self.directory_setting(symbol, directory)
        ivar = "@#{symbol}".to_sym
        define_method symbol do
          instance_variable_set(ivar, Utils.build_path(directory)) unless
            instance_variables.include?(ivar)
          Utils.build_path(instance_variable_get(ivar))
        end
        attr_writer(symbol)
      end

      directory_setting(:controller_dir, 'controllers')
      directory_setting(:helper_dir, 'helpers')
      directory_setting(:layout_dir, 'layouts')
      directory_setting(:public_dir, 'public')
      directory_setting(:view_dir, 'views')
    end
  end
end
