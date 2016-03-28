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
    extend SingleForwardable

    # Collects functionality from all utility modules into a handy class.
    class ToolBelt
      include Application
      include Exceptions
      include FileSystem
      include Helpers
      include Routing
      include Views
    end

    # Embraces a module, making its class methods available as class methods on the current module.
    #
    # @param [Module] mod
    # @return [nil]
    def self.__embrace(mod)
      def_single_delegators(mod, *mod.singleton_methods) && nil
    end

    __embrace(Exceptions)
    __embrace(FileSystem)
  end
end
