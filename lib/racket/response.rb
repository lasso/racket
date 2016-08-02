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
  # Represents a response from the application
  class Response < Rack::Response
    # Generates a basic error response.
    #
    # @param [Fixnum] status
    # @return [Array]
    def self.generate_error_response(status)
      response = new([], status, 'Content-Type' => 'text/plain')
      response.write("#{status} #{Rack::Utils::HTTP_STATUS_CODES[status]}")
      response.finish
    end
  end
end
