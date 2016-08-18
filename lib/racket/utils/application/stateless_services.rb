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
  module Utils
    module Application
      # Collects stateless services across the Racket
      module StatelessServices
        # Returns a list of stateless services (in the form of procs)
        # that Racket uses. This is merely as conveniance method for getting
        # all services from one place, the actual services are spread out over
        # a large number of classes.
        #
        # @return [Hash]
        def self.services
          basic_services
            .merge!(layout_services)
            .merge!(template_services)
            .merge!(view_services)
        end

        def self.basic_services
          {
            action_cache: Racket::Utils::Routing::ActionCache.service,
            application_logger: Racket::Utils::Application::Logger.service,
            handler_stack: Racket::Utils::Application::HandlerStack.service,
            helper_cache: Racket::Utils::Helpers::HelperCache.service,
            router: Racket::Router.service
          }
        end

        def self.layout_services
          {
            layout_cache: Racket::Utils::Views::TemplateCache.service,
            layout_resolver: Racket::Utils::Views::TemplateResolver.service(type: :layout)
          }
        end

        def self.template_services
          {
            template_locator: Racket::Utils::Views::TemplateLocator.service,
            template_renderer: Racket::Utils::Views::Renderer.service
          }
        end

        def self.view_services
          {
            view_cache: Racket::Utils::Views::TemplateCache.service,
            view_manager: Racket::ViewManager.service,
            view_resolver: Racket::Utils::Views::TemplateResolver.service(type: :view)
          }
        end

        private_class_method :basic_services, :layout_services, :template_services, :view_services
      end
    end
  end
end
