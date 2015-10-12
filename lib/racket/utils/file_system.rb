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
            fail ArgumentError, arg unless path_part.relative?
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
      # @return [Pathname]
      def self.build_path(*args)
        PathBuilder.to_pathname(*args)
      end

      # Returns whether a directory is readable or not. In order to be readable, the directory must
      # a) exist
      # b) be a directory
      # c) be readable by the current user
      #
      # @param [Pathname] path
      # @return [true|false]
      def self.dir_readable?(path)
        path.exist? && path.directory? && path.readable?
      end

      # Extracts the correct directory and glob for a given base path/path combination.
      #
      # @param [Pathname] path
      # @return [Array]
      def self.extract_dir_and_glob(path)
        basename = path.basename
        [
          path.dirname,
          path.extname.empty? ? Pathname.new("#{basename}.*") : basename
        ]
      end

      # Given a base pathname and a url path string, returns a pathname.
      #
      # @param [Pathname] base_pathname
      # @param [String] url_path
      # @return [Pathname]
      def self.fs_path(base_pathname, url_path)
        parts = url_path.split('/').reject(&:empty?)
        parts.each { |part| base_pathname = base_pathname.join(part) }
        base_pathname
      end

      # Returns whether a file is readable or not. In order to be readable, the file must
      # a) exist
      # b) be a file
      # c) be readable by the current user
      #
      # @param [Pathname|String] path
      # @return [true|false]
      # @todo Remove temporary workaround for handling string, we want to use Pathname everywhere
      #   possible.
      def self.file_readable?(path)
        # path = Pathname.new(path) unless path.is_a?(Pathname)
        path.exist? && path.file? && path.readable?
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
