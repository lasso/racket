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

module Racket
  module Settings
    # Default values for application
    module ApplicationDefaults
      def default_action
        :index
      end

      def default_content_type
        'text/html'
      end

      def default_controller_helpers
        [:routing, :view]
      end

      def default_layout
        nil
      end

      def default_view
        nil
      end

      def logger
        Logger.new($stdout)
      end

      def middleware
        []
      end

      def mode
        :live
      end

      def plugins
        []
      end

      def session_handler
        [
          Rack::Session::Cookie,
          {
            key: 'racket.session',
            old_secret: SecureRandom.hex(16),
            secret: SecureRandom.hex(16)
          }
        ]
      end

      def root_dir
        Dir.pwd
      end

      def template_settings
        {
          common: {},
          layout: {},
          view: {}
        }
      end

      def warmup_urls
        Set.new
      end

      module_function :default_action, :default_content_type, :default_controller_helpers,
                      :default_layout, :default_view, :logger, :middleware, :mode, :plugins,
                      :session_handler, :root_dir, :template_settings, :warmup_urls
    end
  end
end
