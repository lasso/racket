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
  # Collects utilities needed by different objects in Racket.
  module Utils
    # Utility functions for filesystem.
    module FileSystem
      # Class used for comparing length of paths.
      class SizedPath
        attr_reader :path, :size

        def initialize(path)
          @path = path
          @size = 0
          @path.ascend { @size += 1 }
        end

        # Allow us to compare the current object against other objects of the same type.
        #
        # @param [SizedPath] other
        # @return [Fixnum]
        def <=>(other)
          other.size <=> @size
        end
      end

      # Build path in the filesystem.
      class PathBuilder
        # Creates a new instance of PathBuilder using +args+ and then returning the final path as
        # a Pathname.
        #
        # @param [Array] args
        # @return [Pathname]
        def self.to_pathname(root_dir, *args)
          new(root_dir, args).path
        end

        attr_reader :path

        private

        def initialize(root_dir, args)
          @root_dir = root_dir
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
          @path = Pathname.new(@root_dir).join(@path) if @path.relative?
        end

        def build_path
          @args.each do |arg|
            path_part = Pathname.new(arg)
            raise ArgumentError, arg unless path_part.relative?
            @path = @path.join(path_part)
          end
          remove_instance_variable :@args
        end
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

      # Return a Pathname for a directory if the directory is readable, otherwise returns nil.
      #
      # @param [String] path
      # @return [Pathname|nil]
      def self.dir_or_nil(path)
        return nil unless path
        path = Pathname.new(path)
        dir_readable?(path) ? path : nil
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

      # Returns the first matching path under +base_path+ matching +glob+. If no matching path can
      # be found, +nil+ is returned.
      #
      # @param [Pathname] base_path
      # @param [Pathname] glob
      # @return [Pathname|nil]
      def self.first_matching_path(base_path, glob)
        paths = matching_paths(base_path, glob)
        paths.empty? ? nil : paths.first
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

      # Locates a file in the filesystem matching an URL path. If there exists a matching file,
      # the path to it is returned. If there is no matching file, +nil+ is returned.
      # @param [Pathname] path
      # @return [Pathname|nil]
      def self.resolve_path(path)
        first_matching_path(*extract_dir_and_glob(path))
      end

      # Locates a file in the filesystem matching an URL path. If there exists a matching file,
      # the path to it is returned. If there is no matching file and +default+ is a
      # String or a Symbol, another lookup will be performed using +default+. If
      # +default+ is a Proc or nil, +default+ will be used as is instead.
      #
      # @param [Pathname] path
      # @param [String|Symbol|Proc|nil] default
      # @return [String|Proc|nil]
      def self.resolve_path_with_default(path, default)
        # Return template if it can be found in the file system
        template = resolve_path(path)
        return template if template
        # No template found for path. Try the default template instead.
        # If default template is a string or a symbol, look it up in the file system
        return resolve_path(fs_path(path.dirname, default)) if
          default.is_a?(String) || default.is_a?(Symbol)
        # If default template is a proc or nil, just return it
        default
      end

      # Returns all paths under +base_path+ that matches +glob+.
      #
      # @param [Pathname] base_path
      # @param [Pathname] glob
      # @return [Array]
      def self.matching_paths(base_path, glob)
        return [] unless dir_readable?(base_path)
        Dir.chdir(base_path) { Pathname.glob(glob) }.map { |path| base_path.join(path) }
      end

      # Builds and returns a path in the file system from the provided arguments. The first element
      # in the argument list can be either absolute or relative, all other arguments must be
      # relative, otherwise they will be removed from the final path.
      #
      # @param [Array] args
      # @return [Pathname]
      def build_path(*args)
        PathBuilder.to_pathname(@root_dir, *args)
      end

      # Safely requires a file. This method will catch load errors and return true (if the file
      # was loaded) or false (if the file was not loaded).
      #
      # @param [String] resource
      # @return [true|false]
      def safe_require(resource)
        run_block(LoadError) { require resource }
      end
    end
  end
end
