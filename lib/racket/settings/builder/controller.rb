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
  module Settings
    # Settings Builder module
    module Builder
      # Class for buildning a module for controller settings
      class Controller
        # @param [Racket::Settings::Application] application_settings
        def initialize(application_settings)
          @application_settings = application_settings
        end

        # Builds and returns a module that can be used by controllers
        # to handle settings. Settings are inherited from parent controllers
        # and uses the application settings as a final fallback.
        #
        # @return [Module]
        def build
          klass_mod = build_klass_methods_module
          Module.new do
            define_singleton_method(:included) { |klass| klass.extend(klass_mod) }
            define_method(:setting) { |key, val| settings.store(key, val) }
            define_method(:settings) do
              @instance_settings ||= Racket::Settings::Controller.new(self)
            end
          end
        end

        private

        def build_klass_methods_module
          application_settings = @application_settings
          Module.new do
            define_method(:settings) do
              @klass_settings ||= Racket::Settings::Controller.new(self)
            end
            define_method(:setting) { |key, val| settings.store(key, val) }
            define_method(:__application_settings) { application_settings }
          end
        end
      end
    end
  end
end
