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

require 'logger'
require 'racket/registry'

module Racket
  module Settings
    # Module used for storing default values.
    module Defaults
      # Returns a Racke::Registry object containing application defaults.
      #
      # @return [Racket::Registry]
      def self.application_defaults
        Racket::Registry.with_map(
          default_action: -> { :index },
          default_content_type: -> { 'text/html' },
          default_controller_helpers: -> { [:routing, :view] },
          default_layout: nil_block,
          default_view: nil_block,
          logger: -> { Logger.new($stdout) },
          middleware: array_block,
          mode: -> { :live },
          plugins: array_block,
          session_handler: session_handler,
          root_dir: -> { Dir.pwd },
          template_settings: template_settings,
          warmup_urls: -> { Set.new }
        )
      end

      def self.array_block
        -> { [] }
      end

      def self.nil_block
        -> { nil }
      end

      def self.session_handler
        lambda do
          [
            Rack::Session::Cookie,
            {
              key: 'racket.session',
              old_secret: SecureRandom.hex(16),
              secret: SecureRandom.hex(16)
            }
          ]
        end
      end

      def self.template_settings
        lambda do
          {
            common: {},
            layout: {},
            view: {}
          }
        end
      end

      private_class_method :array_block, :nil_block, :session_handler, :template_settings
    end
  end
end
