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

require_relative 'utils/router.rb'
require_relative 'utils/views.rb'

module Racket
  # Collects utilities needed by different objects in Racket.
  module Utils
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
        fail 'Need a block' unless block_given?
        begin
          true.tap { yield }
        rescue boolean_module(errors)
          false
        end
      end

      # Returns an anonymous module that can be used to rescue exceptions dynamically.
      def self.boolean_module(errors)
        Module.new do
          (class << self; self; end).instance_eval do
            define_method(:===) do |error|
              errors.any? { |err| error.class <= err }
            end
          end
        end
      end

      private_class_method :boolean_module
    end

    # Builds and returns a path in the file system from the provided arguments. The first element
    # in the argument list can be either absolute or relative, all other arguments must be relative,
    # otherwise they will be removed from the final path.
    #
    # @param [Array] args
    # @return [String]
    def self.build_path(*args)
      if args.empty?
        path = Pathname.pwd
      else
        path, args = __base_path(args)
        path = __build_path(path, args)
      end
      path.cleanpath.expand_path.to_s
    end

    def self.dir_readable?(path)
      pathname = Pathname.new(path)
      pathname.exist? && pathname.directory? && pathname.readable?
    end

    def self.file_readable?(path)
      pathname = Pathname.new(path)
      pathname.exist? && pathname.file? && pathname.readable?
    end

    # Runs a block.
    # If no exceptions are raised, this method returns true.
    # If any of the provided error types are raised, this method returns false.
    # If any other exception is raised, this method will just forward the exception.
    #
    # @param [Array] errors
    # @return [true|flase]
    def self.run_block(*errors, &block)
      ExceptionHandler.run_block(errors, &block)
    end

    # :nodoc
    def self.__base_path(args)
      my_args = args.dup.map!(&:to_s)
      path = Pathname.new(my_args.shift)
      path = Pathname.new(Application.settings.root_dir).join(path) if path.relative?
      [path, my_args]
    end

    #:nodoc
    def self.__build_path(path, args)
      args.each do |arg|
        path_part = Pathname.new(arg)
        next unless path_part.relative?
        path = path.join(path_part)
      end
      path
    end

    private_class_method '__base_path'.to_sym, '__build_path'.to_sym
  end
end
