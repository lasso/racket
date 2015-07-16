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
  # Represents the current state of Racket while processing a request. The state gets mixed into
  # the controller instance at the start of the request, making it easy to keep track on everything
  # from within the controller instance.
  class Current
    # Holds Racket internal state, available to the controller instance but mostly used for keeping
    # track of things that don't belong to the actual request.
    State = Struct.new(:action, :action_result, :params)

    # Called whenever a new request needs to be processed.
    #
    # @param [Hash] env Rack environment
    # @param [Symbol] action Keeps track of which action was called on the controller
    # @param [Array] params Parameters sent to the action
    # @return [Module] A module encapsulating all state relating to the current request
    def self.init(env, action, params)
      racket = State.new(action, nil, params)
      request = Request.new(env)
      response = Response.new
      session = Session.new(env['rack.session']) if env.key?('rack.session')
      Module.new do
        define_method(:racket) { racket }
        define_method(:request) { request }
        define_method(:response) { response }
        define_method(:session) { session } if env.key?('rack.session')
      end
    end
  end
end
