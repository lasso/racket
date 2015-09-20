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
  # Class for storing application settings.
  class Settings
    attr_reader :root_dir

    attr_writer :controller_dir, :default_action, :default_content_type,
                :default_controller_helpers, :default_layout, :default_view, :helper_dir,
                :layout_dir, :logger, :middleware, :mode, :public_dir, :root_dir,
                :session_handler, :view_dir

    def initialize(overrides = {})
      @custom = {}
      @root_dir = Utils.build_path(Dir.pwd)
      overrides.each_pair do |key, val|
        send("#{key}=", val)
      end
    end

    # Returns the controller directory associated with the application.
    #
    # @return [String|nil]
    def controller_dir
      @controller_dir = Utils.build_path(@root_dir, 'controllers') unless defined?(@controller_dir)
      Utils.build_path(@controller_dir)
    end

    # Returns a settings value associated with the application. Both standard and custom
    # settings are searched. If the key cannot be found, a default value is returned.
    #
    # @param [Symbol] key
    # @param [Object] default
    # @return [Object]
    def get(key, default = nil)
      meth = key.to_sym
      return send(meth) if respond_to?(meth)
      @custom.fetch(key, default)
    end

    # Sets/updates a setting in the application.
    #
    # @param [Symbol] key
    # @param [Object] value
    # @return [nil]
    def set(key, value)
      meth = "#{key}=".to_sym
      if respond_to?(meth)
        send(meth, value)
      else
        @custom[key] = value
      end
      nil
    end

    # Deletes a setting associated with the application.
    #
    # @param [Symbol] key
    # @return [nil]
    def delete(key)
      fail InvalidArgumentException,
           "Cannot delete standard setting #{key}" if respond_to?(key.to_sym)
      @custom.delete(key) && nil
    end

    # Returns the default action for controllers.
    #
    # @return [Symbol|nil]
    def default_action
      @default_action = :index unless defined?(@default_action)
      @default_action
    end

    # Returns the default content for a controller.
    #
    # @return [String]
    def default_content_type
      @default_content_type ||= 'text/html'
    end

    # Returns a list of default controller helpers.
    #
    # @return [Array]
    def default_controller_helpers
      @default_controller_helpers ||= [:routing, :view]
    end

    # Returns the default layout used for controllers.
    #
    # @return [String|Symbol|nil]
    def default_layout
      @default_layout = nil unless defined?(@default_layout)
      @default_layout
    end

    # Returns the default view used for controllers.
    #
    # @return [String|Symbol|nil]
    def default_view
      @default_view = nil unless defined?(@default_view)
      @default_view
    end

    # Returns the helper directory used by the application.
    #
    # @return [String|nil]
    def helper_dir
      @helper_dir = Utils.build_path(@root_dir, 'helpers') unless defined?(@helper_dir)
      Utils.build_path(@helper_dir)
    end

    # Returns the layout directory used by the application.
    #
    # @return [String|nil]
    def layout_dir
      @layout_dir = Utils.build_path(@root_dir, 'layouts') unless defined?(@layout_dir)
      Utils.build_path(@layout_dir)
    end

    # Returns the logger used by the application.
    #
    # @return [Object]
    def logger
      @logger = Logger.new($stdout) unless defined?(@logger)
      @logger
    end

    # Returns the middleware used by the application.
    #
    # @return [Array]
    def middleware
      @middleware ||= []
    end

    # Returns the the mode the application is running in.
    #
    # @return [Symbol]
    def mode
      @mode ||= :live
    end

    # Returns the public directory used by the application.
    #
    # @return [String|nil]
    def public_dir
      @public_dir = Utils.build_path(@root_dir, 'public') unless defined?(@public_dir)
      Utils.build_path(@public_dir)
    end

    # Returns the session handlers used by the application.
    #
    # @return [Array|nil]
    def session_handler
      @session_handler =
        [
          Rack::Session::Cookie,
          {
            key: 'racket.session',
            old_secret: SecureRandom.hex(16),
            secret: SecureRandom.hex(16)
          }
        ] unless defined?(@session_handler)
      @session_handler
    end

    # Returns the view directory used by the application.
    #
    # @return [String|nil]
    def view_dir
      @view_dir = Utils.build_path(@root_dir, 'views') unless defined?(@view_dir)
      Utils.build_path(@view_dir)
    end
  end
end
