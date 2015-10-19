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

module Racket
  # Collects utilities needed by different objects in Racket.
  module Utils
    # Utility functions for filesystem.
    module Application
      # Class used for building a proper Rack application.
      class ApplicationBuilder
        def initialize(application)
          @application = application
          @settings = @application.settings
          @middleware = @settings.middleware
        end

        # Builds a Rack application representing Racket.
        #
        # @return [Proc]
        def build
          add_middleware
          self.class.build_proc(@application, @middleware)
        end

        private

        def add_middleware
          session_handler = @settings.session_handler
          default_content_type = @settings.default_content_type
          @middleware.unshift(session_handler) if session_handler
          @middleware.unshift([Rack::ContentType, default_content_type]) if default_content_type
          @middleware.unshift([Rack::ShowExceptions]) if @application.dev_mode?
        end

        def self.application_proc(application)
          lambda do |env|
            static_result = application.serve_static_file(env)
            return static_result if static_result && static_result.first < 400
            application.router.route(env)
          end
        end

        def self.build_middleware(builder, application, middleware)
          middleware.each do |ware|
            klass, opts = ware
            application.inform_dev("Loading middleware #{klass} with settings #{opts.inspect}.")
            builder.use(*ware)
          end
        end

        def self.build_proc(application, middleware)
          klass = self
          application_proc = application_proc(application)
          Rack::Builder.new do |builder|
            klass.build_middleware(builder, application, middleware)
            run application_proc
          end
        end

        private_class_method :application_proc
      end
    end
  end
end
