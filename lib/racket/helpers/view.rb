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
  # Helpers module
  module Helpers
    # Helper module that handles views
    module View
      # Renders a template file using the specified context.
      #
      # @param [String] template
      # @param [Object] context
      # @return [String|nil]
      # @todo Allow user to specify template options
      def render_template(template, context = self, template_settings = nil)
        utils = Controller.context.utils
        template = utils.build_path(template)
        return nil unless Racket::Utils::FileSystem.file_readable?(template)
        settings = ::Racket::Utils::Views.extract_template_settings(context, template_settings)
        Tilt.new(template, nil, settings).render(context)
      end
    end
  end
end
