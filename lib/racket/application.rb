=begin
Racket - The noisy Rack MVC framework
Copyright (C) 2015  Lars Olsson <lasso@lassoweb.se>

This file is part of Racket.

Racket is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Racket is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with Racket.  If not, see <http://www.gnu.org/licenses/>.
=end

require 'logger'
require 'rack'

module Racket
  # Racket main application class.
  class Application

    attr_reader :options, :router

    @current = nil

    # Called whenever Rack sends a request to the application.
    #
    # @param [Hash] env Rack environment
    # @return [Array] A Rack response array
    def self.call(env)
      @current.call(env)
    end

    # Returns a route to the specified controller/action/parameter combination
    #
    # @param [Class] controller
    # @param [Symbol] action
    # @param [Array] params
    # @return [String]
    def self.get_route(controller, action, params)
      router.get_route(controller, action, params)
    end

    # Initializes a new Racket::Application object with default options.
    #
    # @return [Class]
    def self.default
      fail 'Application has already been initialized!' if @current
      @current = self.new
      @current.reload
      self
    end

    # Sends a message to the logger, but only if the application is running in dev mode.
    #
    # @param [String] message
    # @param [Symbol] level
    # @return nil
    def self.inform_dev(message, level = :info)
      @current.inform(message, level) if options[:mode] == :dev
      nil
    end

    # Sends a message to the logger.
    #
    # @param [String] message
    # @param [Symbol] level
    # @return nil
    def self.inform_all(message, level = :info)
      @current.inform(message, level)
    end

    # Returns options for the currently running Racket::Application
    #
    # @return [Hash]
    def self.options
      @current.options
    end

    # Returns the router associated with the currenntly running Racket::Application
    #
    # @return [Racket::Router]
    def self.router
      @current.router
    end

    private_class_method :router

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

    # Returns the view cache of the currently running application.
    #
    # @return [ViewCache]
    def self.view_cache
      @current.view_cache
    end

    # Internal dispatch handler. Should not be called directly.
    #
    # @param [Hash] env Rack environment
    # @return [Array] A Rack response array
    def call(env)
      app.call(env)
    end

    # Writes a message to the logger if there is one present
    #
    # @param [String] message
    # @param [Symbol] level
    # @return nil
    def inform(message, level)
      options[:logger].send(level, message) if options[:logger]
      nil
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

    # Returns the ViewCache object associated with the current application.
    #
    # @return [ViewCache]
    def view_cache
      @view_cache ||= ViewCache.new(options[:layout_dir], options[:view_dir])
    end

    private

    def app
      @app ||= build_app
    end

    def build_app
      instance = self
      Rack::Builder.new do
        instance.options[:middleware].each_pair do |klass, opts|
          Application.inform_dev("Loading middleware #{klass} with options #{opts}.")
          use klass, opts
        end
        run lambda { |env| instance.router.route(env) }
      end
    end

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
        default_layout: '_default.*',
        default_view: nil,
        layout_dir: File.join(Dir.pwd, 'layouts'),
        logger: Logger.new($stdout),
        middleware: {
          Rack::Session::Cookie => {
            key: 'racket.session',
            old_secret: SecureRandom.hex(16),
            secret: SecureRandom.hex(16)
          }
        },
        mode: :live,
        view_dir: File.join(Dir.pwd, 'views')
      }
    end

    # Loads controllers and associates each controller with a route
    #
    # @return [nil]
    def load_controllers
      Application.inform_dev('Loading controllers.')
      options[:last_added_controller] = []
      @controller = nil
      Dir.chdir(@options[:controller_dir]) do
        files = Dir.glob(File.join('**', '*.rb'))
        # Sort by longest path so that the longer paths gets matched first
        # HttpRouter claims to be doing this already, but this "hack" is needed in order
        # for the router to work.
        files.sort! do |a, b|
          b.split('/').length <=> a.split('/').length
        end
        files.each do |file|
          require File.absolute_path(file)
          path = "/#{File.dirname(file)}"
          path = '' if path == '/.'
          @router.map(path, options[:last_added_controller].pop)
        end
      end
      options.delete(:last_added_controller)
      Application.inform_dev('Done loading controllers.')
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
