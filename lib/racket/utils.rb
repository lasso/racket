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

require_relative 'utils/application.rb'
require_relative 'utils/exceptions.rb'
require_relative 'utils/file_system.rb'
require_relative 'utils/helpers.rb'
require_relative 'utils/routing.rb'
require_relative 'utils/views.rb'

module Racket
  # Collects utilities needed by different objects in Racket.
  module Utils
    # Collects functionality from all utility modules into a handy class.
    class ToolBelt
      include Application
      include Exceptions
      include FileSystem
      include Helpers
      include Views

      # Returns a service proc that can be used by the registry.
      #
      # @param  [Hash] options
      # @return [Proc]
      def self.service(options = {})
        -> { new(options[:root_dir]) }
      end

      def initialize(root_dir)
        @root_dir = Pathname.new(root_dir).cleanpath.expand_path
      end
    end
  end
end
