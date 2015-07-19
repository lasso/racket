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

require 'logger'

module Racket
  # Racket main application class.
  class Application
    @options = nil

    # Returns the internal application object. When called for the first time this method will use
    # Rack::Builder to build
    #
    # @return [Rack::Builder]
    def self.application
      return @application if @application
      @options[:middleware].unshift([Rack::ShowExceptions]) if dev_mode?
      instance = self
      @application = Rack::Builder.new do
        instance.options[:middleware].each do |middleware|
          klass, opts = middleware
          instance.inform_dev("Loading middleware #{klass} with options #{opts}.")
          use(*middleware)
        end
        run lambda { |env|
          static_result = instance.serve_static_file(env)
          return static_result unless static_result.nil? || static_result.first >= 400
          instance.router.route(env)
        }
      end
    end

    # Called whenever Rack sends a request to the application.
    #
    # @param [Hash] env Rack environment
    # @return [Array] A Rack response array
    def self.call(env)
      application.call(env.dup)
    end

    # Returns a list of default options for Racket::Application.
    #
    # @return [Hash]
    def self.default_options
      root_dir = Utils.build_path(Dir.pwd)
      {
        controller_dir: Utils.build_path(root_dir, 'controllers'),
        default_action: :index,
        default_layout: '_default.*',
        default_view: nil,
        layout_dir: Utils.build_path(root_dir, 'layouts'),
        logger: Logger.new($stdout),
        middleware: [
          [Rack::ContentType],
          [
            Rack::Session::Cookie,
            {
              key: 'racket.session',
              old_secret: SecureRandom.hex(16),
              secret: SecureRandom.hex(16)
            }
          ]
        ],
        mode: :live,
        public_dir: Utils.build_path(root_dir, 'public'),
        root_dir: root_dir,
        view_dir: Utils.build_path(root_dir, 'views')
      }
    end

    # Returns whether the application runs in dev mode.
    #
    # @return [true|false]
    def self.dev_mode?
      @options[:mode] == :dev
    end

    # Returns a route to the specified controller/action/parameter combination.
    #
    # @param [Class] controller
    # @param [Symbol] action
    # @param [Array] params
    # @return [String]
    def self.get_route(controller, action, params)
      @router.get_route(controller, action, params)
    end

    # Initializes a new Racket::Application object with default options.
    #
    # @param [true|false] reboot
    # @return [Class]
    def self.default(reboot = false)
      init({}, reboot)
    end

    # Expands all paths defined in the application.
    #
    # @return [nil]
    def self.expand_paths
      [:controller_dir, :layout_dir, :public_dir, :view_dir].each do |dir|
        @options[dir] = Utils.build_path(@options[dir])
      end && nil
    end

    # Writes a message to the logger if there is one present.
    #
    # @param [String] message
    # @param [Symbol] level
    # @return nil
    def self.inform(message, level)
      (@options[:logger].send(level, message) if @options[:logger]) && nil
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
    # @param [Hash] options
    # @param [true|false] reboot
    # @return [Class]
    def self.init(options, reboot)
      instance_variables.each { |ivar| instance_variable_set(ivar, nil) } if reboot
      fail 'Application has already been initialized!' if @options
      @options = default_options.merge(options)
      expand_paths
      setup_static_server
      reload
      self
    end

    # Loads controllers and associates each controller with a route.
    #
    # @return [nil]
    def self.load_controllers
      inform_dev('Loading controllers.')
      @options[:last_added_controller] = []
      @controller = nil
      Dir.chdir(@options[:controller_dir]) do
        files = Pathname.glob(File.join('**', '*.rb')).map!(&:to_s)
        # Sort by longest path so that the longer paths gets matched first
        # HttpRouter claims to be doing this already, but this "hack" is needed in order
        # for the router to work.
        files.sort! do |a, b|
          b.split('/').length <=> a.split('/').length
        end
        files.each do |file|
          ::Kernel.require File.expand_path(file)
          path = "/#{File.dirname(file)}"
          path = '' if path == '/.'
          @router.map(path, @options[:last_added_controller].pop)
        end
      end
      @options.delete(:last_added_controller)
      inform_dev('Done loading controllers.') && nil
    end

    # Returns options for the currently running Racket::Application.
    #
    # @return [Hash]
    def self.options
      @options
    end

    # Reloads the application, making any changes to the controller configuration visible
    # to the application.
    #
    # @return [nil]
    def self.reload
      setup_routes
      @view_cache = nil
    end

    # Requires a file using the current application directory as a base path.
    #
    # @param [Object] args
    # @return [nil]
    def self.require(*args)
      (::Kernel.require Utils.build_path(*args)) && nil
    end

    # Returns the router associated with the currenntly running Racket::Application.
    #
    # @return [Racket::Router]
    def self.router
      @router
    end

    # Serves a static file (if Racket is configured to serve static files).
    #
    # @param [Hash] env Rack environment
    # @return [Array|nil] A Rack response array if Rack::File handled the file, nil otherwise.
    def self.serve_static_file(env)
      return nil if @static_server.nil?
      @static_server.call(env)
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
      return nil unless (public_dir = @options[:public_dir]) && Utils.dir_readable?(public_dir)
      inform_dev("Setting up static server to serve files from #{public_dir}.")
      (@static_server = Rack::File.new(public_dir)) && nil
    end

    # Initializes a new Racket::Application object with options specified by +options+.
    #
    # @param [Hash] options
    # @param [true|false] reboot
    # @return [Class]
    def self.using(options, reboot = false)
      init(options, reboot)
    end

    # Returns the view cache of the currently running application.
    #
    # @return [ViewCache]
    def self.view_cache
      @view_cache ||= ViewCache.new(@options[:layout_dir], @options[:view_dir])
    end

    private_class_method :application, :default_options, :expand_paths, :inform, :init,
                         :load_controllers, :setup_routes, :setup_static_server
  end
end
