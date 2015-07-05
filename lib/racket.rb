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

require 'pathname'
require 'rack'

require_relative 'racket/application.rb'
require_relative 'racket/controller.rb'
require_relative 'racket/current.rb'
require_relative 'racket/request.rb'
require_relative 'racket/response.rb'
require_relative 'racket/router.rb'
require_relative 'racket/session.rb'
require_relative 'racket/view_cache.rb'
require_relative 'racket/utils.rb'

module Racket
  # Requires a file using the current application directory as a base path.
  #
  # @param [Object] args
  # @return nil
  def require(*args)
    Application.require(*args)
    nil
  end

  # Returns the current version of Racket.
  #
  # @return [String]
  def version
    require_relative 'racket/version.rb'
    Version.current
  end

  module_function :require, :version
end
