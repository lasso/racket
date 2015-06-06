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
  # Represents an incoming request. Mostly matches Rack::Request but removes some methods that
  # don't fit with racket.
  class Request < Rack::Request
    # Force explicit use of request.GET and request.POST
    # For racket params, use racket.params
    undef_method :params

    # Unless sessions are loaded explicitly, session methods should not be available
    undef_method :session, :session_options
  end
end
