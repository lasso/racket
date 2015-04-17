module Racket
  class Application

    attr_reader :options

    @instance = nil

    def self.call(env)
      instance.instance_eval { @router.route(env) }
    end

    def self.instance
      return @instance if @instance
      @instance = self.new
      @instance.instance_eval { setup_routes }
      @instance
    end

    def self.options
      instance.options
    end

    def self.using(options)
      @instance = self.new(options)
      @instance.instance_eval { setup_routes }
      self
    end

    private

    def initialize(options = {})
      @options = default_options.merge(options)
    end

    def default_options
      {
        controller_dir: File.join(Dir.pwd, 'controllers'),
        default_action: :index,
        view_dir: File.join(Dir.pwd, 'views')
      }
    end

    def setup_routes
      @router = Router.new
      @controllers = []
      load_controllers
    end

    def load_controllers
      @controller = nil
      Dir.chdir(@options[:controller_dir]) do
        files = Dir.glob(File.join('**', '*.rb'))
        files.each do |file|
          require File.absolute_path(file)
          path = "/#{File.dirname(file)}"
          path = '' if path == '/.'
          @router.map("#{path}(/*params)", @controller)
        end
      end
      remove_instance_variable :@controller
    end

  end
end
