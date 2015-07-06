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
      if (args.empty?)
        path = Pathname.pwd
      else
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
  end
end
