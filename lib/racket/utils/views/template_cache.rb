# Racket - The noisy Rack MVC framework
# Copyright (C) 2015-2017  Lars Olsson <lasso@lassoweb.se>
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
  module Utils
    module Views
      # Class for caching templates.
      # This class adheres to the Moneta API
      # (https://github.com/minad/moneta#user-content-moneta-api), even though it is not using the
      # Moneta framework.
      class TemplateCache
        # Default options for template cache
        DEFAULT_OPTIONS = { expires: 0 }.freeze

        # Returns a service proc that can be used by the registry.
        #
        # @param  [Hash] _options (unused)
        # @return [Proc]
        def self.service(_options = {})
          -> { new({}) }
        end

        def initialize(options)
          @expirations = {}
          @items = {}
          @options = DEFAULT_OPTIONS.merge(options)
        end

        def [](key)
          load(key)
        end

        def []=(key, value)
          store(key, value)
        end

        def clear(_options = {})
          @expirations.clear
          @items.clear
        end

        def close
          clear
        end

        def create(_key, _value, _options = {})
          raise NotImplementedError
        end

        def decrement(_key, _amount = 1, _options = {})
          raise NotImplementedError
        end

        def delete(key, _options = {})
          @expirations.delete(key)
          @items.delete(key)
        end

        def features
          []
        end

        # This method handles both forms of fetch.
        # With a default block - fetch(key, options = {}, &block)
        # With a default value - fetch(key, value, options = {})
        def fetch(*args)
          key = args.shift
          return load(key) if key?(key)
          block_given? ? yield : args.first
        end

        def increment(_key, _amount = 1, _options = {})
          raise NotImplementedError
        end

        def key?(key)
          @items.key?(key)
        end

        def load(key, _options = {})
          return @items[key] unless @expirations.key?(key)
          if Time.now > @expirations[key]
            @expirations.delete(key)
            @items.delete(key)
          end
          @items[key]
        end

        def store(key, value, options = {})
          set_expiration(key, options.fetch(:expires, @options[:expires]))
          @items[key] = value
        end

        def supports?(feature)
          features.include?(feature)
        end

        private

        def set_expiration(key, expires)
          expire_at = expires > 0 ? Time.now + expires : nil
          if expire_at
            @expirations[key] = expire_at
          else
            @expirations.delete(key)
          end
        end
      end
    end
  end
end
