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
  class Utils
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
        args.map!(&:to_s)
        path = Pathname.new(args.shift)
        path = Pathname.new(Application.options[:root_dir]).join(path) if path.relative?
        args.each do |arg|
          path_part = Pathname.new(arg)
          next unless path_part.relative?
          path = path.join(path_part)
        end
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
  end
end
