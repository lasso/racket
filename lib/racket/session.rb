# Racket - The noisy Rack MVC framework
# Copyright (C) 2015-2018  Lars Olsson <lasso@lassoweb.se>
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
  # Racket::Session is just a thin wrapper around whetever object that is implementing the session
  # storage. By default this is an instance of Rack::Session::Abstract::SessionHash, but
  # Racket::Session will happily wrap anything found in the rack environment.
  #
  # To provide your own session handler and have it wrapped by Racket::Session, just add your
  # session handler as a middleware and make sure it writes the current session to the key
  # rack.session in the rack environment.
  class Session < SimpleDelegator
    # Look the same regardless of what the underlying implementation is.
    def inspect
      "#<#{self.class}:#{object_id}>"
    end
    alias to_s inspect
    alias to_str inspect
  end
end
