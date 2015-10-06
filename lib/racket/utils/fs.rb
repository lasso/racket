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
    attr_reader :path
    # Utility functions for filesystem.
    module FS
      # Build path in the filesystem.
      class PathBuilder
        def initialize(*args)
          extract_base_path(args.dup)
          build_path
          clean_path
        end

        # Returns the PathBuilder as as string
        #
        # @return [String]
        def to_s
          @path.to_s
        end

        private

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
    end
  end
end
