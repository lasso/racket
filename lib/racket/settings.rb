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

module Racket
  # Class for storing application settings.
  class Settings
    attr_reader :root_dir

    attr_writer :controller_dir, :default_action, :default_content_type,
                :default_controller_helpers, :default_layout, :default_view, :helper_dir,
                :layout_dir, :logger, :middleware, :mode, :public_dir, :root_dir,
                :session_handler, :view_dir

    def initialize(overrides = {})
      @custom = {}
      @root_dir = Utils.build_path(Dir.pwd)
      overrides.each_pair do |key, val|
        next if key.to_sym == :root_dir
        send("#{key}=", val)
      end
    end

    def controller_dir
      Utils.build_path(@controller_dir ||= Utils.build_path(@root_dir, 'controllers'))
    end

    def get(key, default = nil)
      @custom.fetch(key, default)
    end

    def set(key, value)
      @custom[key] = value
    end

    def delete(key)
      @custom.delete(key)
    end

    def default_action
      @default_action ||= :index
    end

    def default_content_type
      @default_content_type ||= 'text/html'
    end

    def default_controller_helpers
      @default_controller_helpers ||= [:routing, :view]
    end

    def default_layout
      @default_layout ||= nil
    end

    def default_view
      @default_view ||= nil
    end

    def helper_dir
      Utils.build_path(@helper_dir ||= Utils.build_path(@root_dir, 'helpers'))
    end

    def layout_dir
      Utils.build_path(@layout_dir ||= Utils.build_path(@root_dir, 'layouts'))
    end

    def logger
      @logger ||= Logger.new($stdout)
    end

    def middleware
      @middleware ||= []
    end

    def mode
      @mode ||= :live
    end

    def public_dir
      Utils.build_path(@public_dir ||= Utils.build_path(@root_dir, 'public'))
    end

    def session_handler
      @session_handler ||=
        [
          Rack::Session::Cookie,
          {
            key: 'racket.session',
            old_secret: SecureRandom.hex(16),
            secret: SecureRandom.hex(16)
          }
        ]
    end

    def view_dir
      Utils.build_path(@view_dir ||= Utils.build_path(@root_dir, 'views'))
    end
  end
end
