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
    def self.calculate_url_path(file)
      url_path = "/#{file.relative_path_from(settings.controller_dir).dirname}"
      url_path = '' if url_path == '/.'
      url_path
    end

    # Called whenever Rack sends a request to the application.
    #
    # @param [Hash] env Rack environment
    # @return [Array] A Rack response array
    def self.call(env)
      @registry.handler_stack.call(env.dup)
    end

    # Returns whether the application runs in dev mode.
    #
    # @return [true|false]
    def self.dev_mode?
      settings.mode == :dev
    end

    # Returns a route to the specified controller/action/parameter combination.
    #
    # @param [Class] controller
    # @param [Symbol] action
    # @param [Array] params
    # @return [String]
    def self.get_route(controller, action = nil, *params)
      router.get_route(controller, action, params)
    end

    # Initializes a new Racket::Application object with default settings.
    #
    # @return [Class]
    def self.default
      init
    end

    # Sends a message to the logger.
    #
    # @param [String] message
    # @param [Symbol] level
    # @return nil
    def self.inform_all(message, level = :info)
      @registry.application_logger.inform_all(message, level)
    end

    # Sends a message to the logger, but only if the application is running in dev mode.
    #
    # @param [String] message
    # @param [Symbol] level
    # @return nil
    def self.inform_dev(message, level = :debug)
      @registry.application_logger.inform_dev(message, level)
    end

    # Initializes the Racket application.
    #
    # @param [Hash] settings
    # @return [Class]
    def self.init(settings = {})
      @registry = Utils::Application::RegistryBuilder.new(settings).registry
      @registry.handler_stack # Makes sure all plugins and helpers are loaded before any controllers
      reload
      self
      # Return application from registry
    end

    # Loads controllers and associates each controller with a route.
    #
    # @return [nil]
    def self.load_controllers
      inform_dev('Loading controllers.')
      Controller.__set_context(@registry.controller_context)
      settings.store(:last_added_controller, [])
      load_controller_files
      settings.delete(:last_added_controller)
      inform_dev('Done loading controllers.') && nil
    end

    # Loads a controller file.
    #
    # @param [String] file Relative path from controller dir
    # @return nil
    def self.load_controller_file(file)
      ::Kernel.require file
      klass = settings.fetch(:last_added_controller).pop
      # Helpers may do stuff based on route, make sure it is available before applying helpers.
      router.map(calculate_url_path(file), klass)
      utils.apply_helpers(klass) && nil
    end

    def self.load_controller_files
      utils.paths_by_longest_path(settings.controller_dir, File.join('**', '*.rb')).each do |path|
        load_controller_file(path)
      end
    end

    # @return [Racket::Registry]
    def self.registry
      @registry
    end

    # Reloads the application, making any changes to the controller configuration visible
    # to the application.
    #
    # @return [nil]
    def self.reload
      load_controllers
      @view_manager = nil
    end

    # Requires a file using the current application directory as a base path.
    #
    # @TODO: Clean this mess up when Application stops being a sigleton.
    # @param [Object] args
    # @return [nil]
    def self.require(*args)
      registry = @registry || Utils::Application::RegistryBuilder.new({}).registry
      (::Kernel.require registry.utils.build_path(*args)) && nil
    end

    # Returns the router associated with the application.
    #
    # @return [Racket::Router]
    def self.router
      @registry.router
    end

    # Returns settings for the application
    #
    # @return [Racket::Settings::Application]
    def self.settings
      @registry.application_settings
    end

    # Initializes a new Racket::Application object with settings specified by +settings+.
    #
    # @param [Hash] settings
    # @return [Class]
    def self.using(settings)
      init(settings)
    end

    def self.utils
      @registry.utils
    end

    # Returns the view cache of the currently running application.
    #
    # @return [Racket::ViewManager]
    def self.view_manager
      @view_manager ||= @registry.view_manager
    end

    private_class_method :calculate_url_path, :init, :load_controller_file,
                         :load_controller_files, :load_controllers, :utils
  end
end
