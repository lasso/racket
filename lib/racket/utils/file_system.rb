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
    module FileSystem
      # Build path in the filesystem.
      class PathBuilder
        # Creates a new instance of PathBuilder using +args+ and then returning the final path as
        # a Pathname.
        #
        # @param [Array] args
        # @return [Pathname]
        def self.to_pathname(*args)
          new(args).path
        end

        # Creates a new instance of PathBuilder using +args+ and then returning the final path as
        # a string.
        #
        # @param [Array] args
        # @return [String]
        def self.to_s(*args)
          new(args).path.to_s
        end

        attr_reader :path

        private

        def initialize(args)
          extract_base_path(args.dup)
          build_path
          clean_path
        end

        def clean_path
          @path = @path.cleanpath.expand_path
        end

        def extract_base_path(args)
          if (@args = args).empty?
            @path = Pathname.pwd
            return
          end
          @args.map!(&:to_s)
          @path = Pathname.new(@args.shift)
          @path = Pathname.new(::Racket::Application.settings.root_dir).join(@path) if
            @path.relative?
        end

        def build_path
          @args.each do |arg|
            path_part = Pathname.new(arg)
            next unless path_part.relative?
            @path = @path.join(path_part)
          end
          remove_instance_variable :@args
        end
      end

      # Builds and returns a path in the file system from the provided arguments. The first element
      # in the argument list can be either absolute or relative, all other arguments must be
      # relative, otherwise they will be removed from the final path.
      #
      # @param [Array] args
      # @return [String]
      def self.build_path(*args)
        PathBuilder.to_s(*args)
      end

      # Returns whether a directory is readable or not. In order to be readable, the directory must
      # a) exist
      # b) be a directory
      # c) be readable by the current user
      #
      # @param [String] path
      # @return [true|false]
      def self.dir_readable?(path)
        pathname = PathBuilder.to_pathname(path)
        pathname.exist? && pathname.directory? && pathname.readable?
      end

      # Returns whether a file is readable or not. In order to be readable, the file must
      # a) exist
      # b) be a file
      # c) be readable by the current user
      #
      def self.file_readable?(path)
        pathname = PathBuilder.to_pathname(path)
        pathname.exist? && pathname.file? && pathname.readable?
      end

      # Returns a list of relative file paths, sorted by path (longest first).
      #
      # @param [String] base_dir
      # @param [String] glob
      # return [Array]
      def self.files_by_longest_path(base_dir, glob)
        Dir.chdir(base_dir) do
          # Get a list of matching files
          files = Pathname.glob(glob).map!(&:to_s)
          # Sort by longest path.
          files.sort! { |first, second| second.split('/').length <=> first.split('/').length }
          files
        end
      end
    end
  end
end
