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
  # Racket main application class.
  class Application
    # Initializes a new Racket::Application object with default settings.
    #
    # @return [Class]
    def self.default
      new
    end

    # Initializes a new Racket::Application object with settings specified by +settings+.
    #
    # @param [Hash] settings
    # @return [Class]
    def self.using(settings)
      new(settings)
    end

    attr_reader :registry

    # Initializes the Racket application.
    #
    # @param [Hash] settings
    # @return [Class]
    def initialize(settings = {})
      @registry = Utils::Application::RegistryBuilder.new(settings).registry
      @registry.handler_stack # Makes sure all plugins and helpers are loaded before any controllers
      load_controllers
    end

    # Called whenever Rack sends a request to the application.
    #
    # @param [Hash] env Rack environment
    # @return [Array] A Rack response array
    def call(env)
      @registry.handler_stack.call(env.dup)
    end

    # Returns whether the application runs in dev mode.
    #
    # @return [true|false]
    def dev_mode?
      @registry.application_settings.mode == :dev
    end

    # Sends a message to the logger.
    #
    # @param [String] message
    # @param [Symbol] level
    # @return nil
    def inform_all(message, level = :info)
      @registry.application_logger.inform_all(message, level)
    end

    # Sends a message to the logger, but only if the application is running in dev mode.
    #
    # @param [String] message
    # @param [Symbol] level
    # @return nil
    def inform_dev(message, level = :debug)
      @registry.application_logger.inform_dev(message, level)
    end

    alias kernel_require require

    # Requires a file using the current application directory as a base path.
    #
    # @param [Object] args
    # @return [nil]
    def require(*args)
      (kernel_require @registry.utils.build_path(*args)) && nil
    end

    private

    # Calculates the url path for the specified (controller) file
    #
    # @param [Pathname] file
    # @return [String]
    def calculate_url_path(file)
      controller_dir = @registry.application_settings.controller_dir
      url_path = "/#{file.relative_path_from(controller_dir).dirname}"
      url_path = '' if url_path == '/.'
      url_path
    end

    # Returns a list of relative file paths representing controllers,
    # sorted by path length (longest first).
    #
    # return [Array]
    def controller_files
      controller_dir = @registry.application_settings.controller_dir
      glob = File.join('**', '*.rb')
      Utils::FileSystem.matching_paths(controller_dir, glob).map do |path|
        Utils::FileSystem::SizedPath.new(path)
      end.sort.map(&:path)
    end

    # Loads controllers and associates each controller with a route.
    #
    # @return [nil]
    def load_controllers
      inform_dev('Loading controllers.')
      Controller.context = @registry.controller_context
      load_controller_files
      inform_dev('Done loading controllers.') && nil
    end

    # Loads a controller file.
    #
    # @param [String] file Relative path from controller dir
    # @return nil
    def load_controller_file(file)
      kernel_require file
      klass = @registry.application_settings.fetch(:last_added_controller).pop
      # Helpers may do stuff based on route, make sure it is available before applying helpers.
      @registry.router.map(calculate_url_path(file), klass)
      @registry.utils.apply_helpers(klass) && nil
    end

    def load_controller_files
      settings = @registry.application_settings
      settings.store(:last_added_controller, [])
      controller_files.each { |path| load_controller_file(path) }
      settings.delete(:last_added_controller)
    end
  end
end
