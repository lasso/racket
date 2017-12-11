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
module Racket
  # Collects modules that are included by the core classes.
  module Modules
    # View methods used by the Controller class.
    module ControllerViews
      module ClassMethods
        # Returns the layout settings for the current controller.
        #
        # @return [Hash]
        def layout_settings
          template_settings = settings.fetch(:template_settings)
          template_settings[:common].merge(template_settings[:layout])
        end

        # Add a setting used by Tilt when rendering views/layouts.
        #
        # @param [Symbol] key
        # @param [Object] value
        # @param [Symbol] type One of +:common+, +:layout+ or +:view+
        def template_setting(key, value, type = :common)
          # If controller has no template settings on its own, copy the template settings
          # from its "closest" parent (might even be application settings)
          # @todo - How about template options that are unmarshallable?
          settings.store(
            :template_settings, Marshal.load(Marshal.dump(settings.fetch(:template_settings)))
          ) unless settings.present?(:template_settings)

          # Fetch current settings (guaranteed to be in controller by now)
          template_settings = settings.fetch(:template_settings)

          # Update settings
          template_settings[type][key] = value
          settings.store(:template_settings, template_settings)
        end

        # Returns the view settings for the current controller.
        #
        # @return [Hash]
        def view_settings
          template_settings = settings.fetch(:template_settings)
          template_settings[:common].merge(template_settings[:view])
        end
      end

      extend ClassMethods

      # Returns layout settings associated with the current controller
      def layout_settings
        self.class.layout_settings
      end

      # Returns view settings associated with the current controller
      def view_settings
        self.class.view_settings
      end
    end
  end
end