module Racket
  class Application

    attr_reader :options, :router

    @current = nil

    # Called whenever Rack sends a request to the application.
    #
    # @param [Hash] env Rack environment
    # @return [Array] A Rack response array
    def self.call(env)
      current.router.route(env)
    end

    # Returns the currently running Racket::Application object.
    #
    # @return [Racket::Application]
    def self.current
      return @current if @current
      default
    end

    private_class_method :current

    # Initializes a new Racket::Application object with default options.
    #
    # @return [Class]
    def self.default
      fail 'Application has already been initialized!' if @current
      @current = self.new
      @current.reload
      self
    end

    # Returns options for the currently running Racket::Application
    #
    # @return [Hash]
    def self.options
      current.options
    end

    # Returns the router associated with the currenntly running Racket::Application
    #
    # @return [Racket::Router]
    def self.router
      current.router
    end

    # Initializes a new Racket::Application object with options specified by +options+.
    #
    # @param [Hash] options
    # @return [Class]
    def self.using(options)
      fail 'Application has already been initialized!' if @current
      @current = self.new(options)
      @current.reload
      self
    end

    # Reloads the application, making any changes to the controller configuration visible
    # to the application.
    #
    # @return [nil]
    def reload
      setup_routes
      # @todo: Clear cached views/layouts
      nil
    end

    private

    # Creates a new instance of Racket::Application
    #
    # @param [Hash] options
    # @return [Racket::Application]
    def initialize(options = {})
      @options = default_options.merge(options)
    end

    # Returns a list of default options for Racket::Application
    #
    # @return [Hash]
    def default_options
      {
        controller_dir: File.join(Dir.pwd, 'controllers'),
        default_action: :index,
        view_dir: File.join(Dir.pwd, 'views')
      }
    end

    # Loads controllers and associates each controller with a route
    #
    # @return [nil]
    def load_controllers
      options[:last_added_controller] = nil
      @controller = nil
      Dir.chdir(@options[:controller_dir]) do
        files = Dir.glob(File.join('**', '*.rb'))
        files.each do |file|
          require File.absolute_path(file)
          path = "/#{File.dirname(file)}"
          path = '' if path == '/.'
          @router.map("#{path}(/*params)", options[:last_added_controller])
        end
      end
      options.delete(:last_added_controller)
      nil
    end

    # Initializes routing
    #
    # @return [nil]
    def setup_routes
      @router = Router.new
      load_controllers
      nil
    end

  end
end
