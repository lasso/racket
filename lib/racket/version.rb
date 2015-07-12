=begin
Racket - The noisy Rack MVC framework
Copyright (C) 2015  Lars Olsson <lasso@lassoweb.se>

This file is part of Racket.

Racket is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Racket is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with Racket.  If not, see <http://www.gnu.org/licenses/>.
=end

module Racket
  # The only purpose of this module is to keep track of the current Racket version. It is *not*
  # loaded automatically unless you make an explicit call to Racket.version.
  module Version
    # Major version
    MAJOR = 0
    # Minor version
    MINOR = 0
    # Teeny version
    TEENY = 4

    # Returns the current version of Racket as a string.
    #
    # @return [String]
    def current
      [MAJOR, MINOR, TEENY].join('.')
    end

    module_function :current
  end
end
