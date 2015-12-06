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
  # Racket main application class.
  class Application
    @settings = nil

    class << self
      attr_reader :router, :settings
    end

    # Returns the internal application object. When called for the first time this method will use
    # Rack::Builder to construct the application.
    #
    # @return [Rack::Builder]
    def self.application
      @application ||= Utils.build_application(self)
    end

    def self.calculate_url_path(file)
      url_path = "/#{file.relative_path_from(@settings.controller_dir).dirname}"
      url_path = '' if url_path == '/.'
      url_path
    end

    # Called whenever Rack sends a request to the application.
    #
    # @param [Hash] env Rack environment
    # @return [Array] A Rack response array
    def self.call(env)
      application.call(env.dup)
    end

    # Returns whether the application runs in dev mode.
    #
    # @return [true|false]
    def self.dev_mode?
      @settings.mode == :dev
    end

    # Returns a route to the specified controller/action/parameter combination.
    #
    # @param [Class] controller
    # @param [Symbol] action
    # @param [Array] params
    # @return [String]
    def self.get_route(controller, action = nil, *params)
      @router.get_route(controller, action, params)
    end

    # Initializes a new Racket::Application object with default settings.
    #
    # @return [Class]
    def self.default
      init
    end

    # Writes a message to the logger if there is one present.
    #
    # @param [String] message
    # @param [Symbol] level
    # @return nil
    def self.inform(message, level)
      logger = @settings.logger
      (logger.send(level, message) if logger) && nil
    end

    # Sends a message to the logger.
    #
    # @param [String] message
    # @param [Symbol] level
    # @return nil
    def self.inform_all(message, level = :info)
      inform(message, level)
    end

    # Sends a message to the logger, but only if the application is running in dev mode.
    #
    # @param [String] message
    # @param [Symbol] level
    # @return nil
    def self.inform_dev(message, level = :debug)
      (inform(message, level) if dev_mode?) && nil
    end

    # Initializes the Racket application.
    #
    # @param [Hash] settings
    # @return [Class]
    def self.init(settings = {})
      fail 'Application has already been initialized!' if @settings
      @settings = Settings::Application.new(settings)
      setup_static_server
      reload
      self
    end

    # Loads controllers and associates each controller with a route.
    #
    # @return [nil]
    def self.load_controllers
      inform_dev('Loading controllers.')
      @settings.store(:last_added_controller, [])
      load_controller_files
      @settings.delete(:last_added_controller)
      inform_dev('Done loading controllers.') && nil
    end

    # Loads a controller file.
    #
    # @param [String] file Relative path from controller dir
    # @return nil
    def self.load_controller_file(file)
      ::Kernel.require file
      klass = @settings.fetch(:last_added_controller).pop
      Utils.apply_helpers(klass)
      @router.map(calculate_url_path(file), klass) && nil
    end

    def self.load_controller_files
      Utils.paths_by_longest_path(@settings.controller_dir, File.join('**', '*.rb')).each do |path|
        load_controller_file(path)
      end
    end

    # Reloads the application, making any changes to the controller configuration visible
    # to the application.
    #
    # @return [nil]
    def self.reload
      setup_routes
      @view_manager = nil
    end

    # Requires a file using the current application directory as a base path.
    #
    # @param [Object] args
    # @return [nil]
    def self.require(*args)
      (::Kernel.require Utils.build_path(*args)) && nil
    end

    # Resets Racket::Application, making it possible to run run a new application with new settings.
    # This is a workaround for Racket::Application being a singleton, making tests harder to write,
    # @todo Remove this when Racket::Application stops beeing a singleton (if ever).
    def self.reset!
      instance_variables.each { |ivar| instance_variable_set(ivar, nil) }
    end

    # Serves a static file (if Racket is configured to serve static files).
    #
    # @param [Hash] env Rack environment
    # @return [Array|nil] A Rack response array if Rack::File handled the file, nil otherwise.
    def self.serve_static_file(env)
      @static_server ? @static_server.call(env) : nil
    end

    # Initializes routing.
    #
    # @return [nil]
    def self.setup_routes
      @router = Router.new
      load_controllers
    end

    # Initializes static server (if a public dir is specified).
    #
    # @return [nil]
    def self.setup_static_server
      @static_server = nil
      return nil unless (public_dir = @settings.public_dir) &&
                        Utils.dir_readable?(Pathname.new(public_dir))
      inform_dev("Setting up static server to serve files from #{public_dir}.")
      (@static_server = Rack::File.new(public_dir)) && nil
    end

    # Initializes a new Racket::Application object with settings specified by +settings+.
    #
    # @param [Hash] settings
    # @return [Class]
    def self.using(settings)
      init(settings)
    end

    # Returns the view cache of the currently running application.
    #
    # @return [Racket::ViewManager]
    def self.view_manager
      @view_manager ||= ViewManager.new(@settings.layout_dir, @settings.view_dir)
    end

    private_class_method :application, :calculate_url_path, :inform, :init, :load_controller_file,
                         :load_controller_files, :load_controllers, :setup_routes,
                         :setup_static_server
  end
end
