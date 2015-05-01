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
  class Controller

    def self.inherited(klass)
      Application.options[:last_added_controller] = klass
    end

    def default_action
      Application.options[:default_action]
    end

    def rs(action, *params)
      Application.get_route(self.class, action, params)
    end

    def r(controller, action, *params)
      Application.get_route(controller, action, params)
    end

    def render(action)
      __execute(action)
      Application.view_cache.render(self)
    end

    private

    def __execute(action)
      meth = method(action)
      response.action_result = case meth.arity
        when 0 then meth.call
        else meth.call(params[0...meth.arity])
      end
    end

  end
end
