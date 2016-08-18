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
  module Utils
    # Utility functions for options handling.
    module Options
      # Validates that all required options are not false or nil
      # in a list of options.
      #
      # @param [Hash] required
      # @param [Hash] incoming
      # @return nil
      # @raise ArgumentError
      def self.validate_options(required, incoming)
        required.each_pair do |key, message|
          raise ArgumentError, message unless incoming[key]
        end
        nil
      end
    end
  end
end
