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

require 'pathname'
require 'rack'

require_relative 'racket/application.rb'
require_relative 'racket/modules/controller_views.rb'
require_relative 'racket/modules/controller_hooks.rb'
require_relative 'racket/controller.rb'
require_relative 'racket/current.rb'
require_relative 'racket/request.rb'
require_relative 'racket/response.rb'
require_relative 'racket/router.rb'
require_relative 'racket/session.rb'
require_relative 'racket/settings/application.rb'
require_relative 'racket/settings/controller.rb'
require_relative 'racket/view_manager.rb'
require_relative 'racket/utils.rb'

# Racket main namespace
module Racket
  class << self
    alias kernel_require require
  end

  # Requires a file relative to the current Racket application dir. Will raise an exception if no
  # Racket application is initialized.
  #
  # @param [Array] args
  # @return nil
  def require(*args)
    raise 'You must have a running Racket application before calling Racket.require' unless
      Controller.context
    (kernel_require resource_path(*args)) && nil
  end

  # Returns the path to a resource relative to the Racket application dir. Will raise an exception
  # if no Racket is initialized.
  #
  # @param [Array] args
  # @return [Pathname]
  def resource_path(*args)
    context = Controller.context
    raise 'You must have a running Racket application before calling Racket.resource_path' unless
      context
    context.utils.build_path(*args)
  end

  # Returns the current version of Racket.
  #
  # @return [String]
  def version
    Kernel.require_relative 'racket/version.rb'
    Version.current
  end

  module_function :require, :resource_path, :version
end
