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
  module Current
    State = Struct.new(:action, :action_result, :params, :redirected)

    def self.init(env, action, params)
      racket = State.new
      racket.action = action
      racket.params = params
      racket.redirected = false
      request = Request.new(env)
      response = Response.new
      Module.new do
        define_method(:racket) { racket }
        define_method(:request) { request }
        define_method(:response) { response }
      end
    end
  end
end
