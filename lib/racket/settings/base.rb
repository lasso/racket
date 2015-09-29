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
  module Settings
    # Base class for settings.
    class Base
      def initialize(defaults = {})
        @custom = {}
        defaults.each_pair do |key, value|
          meth = "#{key}=".to_sym
          if respond_to?(meth) then send(meth, value)
          else @custom[key] = value
          end
        end
      end

      # Deletes a custom setting associated with the application.
      #
      # @param [Symbol] key
      # @return [nil]
      def delete(key)
        fail ArgumentErrpr,
             "Cannot delete standard setting #{key}" if respond_to?(key.to_sym)
        @custom.delete(key) && nil
      end

      # Returns a settings value associated with the application. Both standard and custom
      # settings are searched. If the key cannot be found, a default value is returned.
      #
      # @param [Symbol] key
      # @param [Object] default
      # @return [Object]
      def fetch(key, default = nil)
        meth = key.to_sym
        return send(meth) if respond_to?(meth)
        @custom.fetch(key, default)
      end

      def key?(key)
        @custom.key?(key)
      end

      # Sets/updates a custom setting in the application.
      #
      # @param [Symbol] key
      # @param [Object] value
      # @return [nil]
      def store(key, value)
        fail ArgumentError,
             "Cannot overwrite standard setting #{key}" if respond_to?("#{key}=".to_sym)
        (@custom[key] = value) && nil
      end

      # Creates a setting with a default value.
      #
      # @param [Symbol] symbol
      # @param [Object] default
      # @param [true|false] writable
      # @return [nil]
      def self.setting(symbol, default = nil, writable = true)
        ivar = "@#{symbol}".to_sym
        define_method symbol do
          instance_variable_set(ivar, default) unless instance_variables.include?(ivar)
          instance_variable_get(ivar)
        end
        (attr_writer(symbol) if writable) && nil
      end
    end
  end
end
