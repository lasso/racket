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
  # Represents an incoming request. Mostly matches Rack::Request but removes/redefines
  # methods relating to GET/POST parameters and sessions.
  class Request < Rack::Request
    # Remove methods that use merged GET and POST data.
    undef_method :[], :[]=, :delete_param, :params, :update_param

    # Remove session methods.
    undef_method :session, :session_options

    # Rename methods for handling GET parameters
    alias_method(:get_params, :GET)
    undef_method :GET

    # Rename methods for handling POST parameters
    alias_method(:post_params, :POST)
    undef_method :POST
  end
end
