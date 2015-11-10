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
  # Racket plugin registry.
  class PluginManager
    def self.add(plugin, settings = {})
      Utils.safe_require("racket/plugins/#{plugin}.rb")
      mod = Racket::Plugins.const_get(plugin.to_s.split('_').collect(&:capitalize).join.to_sym)
      mod.init(settings) if mod.respond_to?(:init)
      (plugins << mod) && nil
    end

    def self.plugins
      @plugins ||= []
    end
  end
end
