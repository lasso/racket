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
  # Collects utilities needed by different objects in Racket.
  module Utils
    # Utility functions for filesystem.
    module Exceptions
      # Handles exceptions dynamically
      class ExceptionHandler
        # Runs a block.
        # If no exceptions are raised, this method returns true.
        # If any of the provided error types are raised, this method returns false.
        # If any other exception is raised, this method will just forward the exception.
        #
        # @param [Array] errors
        # @return [true|flase]
        def self.run_block(errors)
          raise 'Need a block' unless block_given?
          begin
            true.tap { yield }
          rescue boolean_module(errors)
            false
          end
        end

        # Returns an anonymous module that can be used to rescue exceptions dynamically.
        def self.boolean_module(errors)
          Module.new do
            singleton_class.instance_eval do
              define_method(:===) do |error|
                errors.any? { |err| error.class <= err }
              end
            end
          end
        end

        private_class_method :boolean_module
      end

      # Runs a block.
      # If no exceptions are raised, this method returns true.
      # If any of the provided error types are raised, this method returns false.
      # If any other exception is raised, this method will just forward the exception.
      #
      # @param [Array] errors
      # @return [true|flase]
      def run_block(*errors, &block)
        ExceptionHandler.run_block(errors, &block)
      end
    end
  end
end
