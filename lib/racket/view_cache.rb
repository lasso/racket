require 'tilt'

module Racket

  class ViewCache

    def initialize(layout_base_dir, template_base_dir)
      @layout_base_dir = layout_base_dir
      @template_base_dir = template_base_dir
      @layouts_by_path = {}
      @templates_by_path = {}
    end

    def render(controller)
      # @todo: layout!
      template = find_template(controller.request.path)
      controller.response.write(
        template ?
        Tilt.new(template).render(controller) :
        controller.response.action_result
      )
      controller.response.finish
    end

    private

    # Tries to locate a layout matching +url_path+ in the file system and returns the path if a
    # matching file is found. If no matching file is found, +nil+ is returned. The result is
    # cached, meaning that the filesystem lookup for a specific url_path will only happen once.
    #
    # @param [String] url_path
    # @return [String|nil]
    def find_layout(url_path)
      return @layouts_by_path[url_path] if @layouts_by_path.key?(url_path)
      @layouts_by_path[url_path] =
        find_matching_file(@layout_base_dir, url_path, Application.options[:default_layout])
    end

    # Tries to locate a template matching +url_path+ in the file system and returns the path if a
    # matching file is found. If no matching file is found, +nil+ is returned. The result is
    # cached, meaning that the filesystem lookup for a specific url_path will only happen once.
    #
    # @param [String] url_path
    # @return [String|nil]
    def find_template(url_path)
      return @templates_by_path[url_path] if @templates_by_path.key?(url_path)
      @templates_by_path[url_path] = find_matching_file(@template_base_dir, url_path)
    end

    # Locates a file in the filesystem matching an URL path. If there exists a matching file, the
    # path to it is returned. If there is no matching file, +nil+ is returned.
    #
    # @param [String] base_file_path
    # @param [String] url_path
    # @param [String|nil] default_file
    # @return [String|nil]
    def find_matching_file(base_file_path, url_path, default_file = nil)
      file_path = File.join(base_file_path, url_path)
      action = File.basename(file_path)
      file_path = File.dirname(file_path)
      return nil unless File.exists?(file_path) && File.directory?(file_path)
      Dir.chdir(file_path) do
        files = Dir.glob("#{action}.*")
        if files.empty?
          if default_file
            files = Dir.glob("_default.*")
            return nil if files.empty?
            return File.join(file_path, files.first)
          end
        end
        File.join(file_path, files.first)
      end
    end

  end

end
