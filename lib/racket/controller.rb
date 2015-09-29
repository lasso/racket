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
  # Base controller class. Your controllers should inherit this class.
  class Controller
    def self.__load_helpers(helpers)
      helper_dir = Application.settings.helper_dir
      helper_modules = {}
      helpers.each do |helper|
        helper_module = helper.to_s.split('_').collect(&:capitalize).join.to_sym
        Utils.run_block(NameError) do
          Utils.run_block(LoadError) { require "racket/helpers/#{helper}" } ||
            (helper_dir &&
              Utils.run_block(LoadError) { require Utils.build_path(helper_dir, helper) }
            )
          helper_modules[helper] = Racket::Helpers.const_get(helper_module)
          Application.inform_dev("Added helper module #{helper.inspect} to class #{self}.")
        end ||
          Application.inform_dev(
            "Failed to add helper module #{helper.inspect} to class #{self}.", :warn
          )
      end
      helper_modules
    end

    private_class_method :__load_helpers

    # Adds a hook to one or more actions.
    #
    # @param [Symbol] type
    # @param [Array] methods
    # @param [Proc] blk
    # @return [nil]
    def self.__register_hook(type, methods, blk)
      key = "#{type}_hooks".to_sym
      meths = public_instance_methods(false)
      meths &= methods.map(&:to_sym) unless methods.empty?
      hooks = settings.fetch(key, {})
      meths.each { |meth| hooks[meth] = blk }
      setting(key, hooks)
      nil
    end

    private_class_method :__register_hook

    # Adds a before hook to one or more actions. Actions should be given as a list of symbols.
    # If no symbols are provided, *all* actions on the controller is affected.
    #
    # @param [Array] methods
    # @return [nil]
    def self.after(*methods, &blk)
      __register_hook(:after, methods, blk) if block_given?
    end

    # Adds an after hook to one or more actions. Actions should be given as a list of symbols.
    # If no symbols are provided, *all* actions on the controller is affected.
    #
    # @param [Array] methods
    # @return [nil]
    def self.before(*methods, &blk)
      __register_hook(:before, methods, blk) if block_given?
    end

    # Adds one or more helpers to the controller. All controllers get some default helpers
    # (:routing and :view by default), but if you have your own helpers you want to load this
    # is the preferred method.
    #
    # By default Racket will look for your helpers in the helpers directory, but you can specify
    # another location by changing the helper_dir setting.
    #
    # @param [Array] helpers An array of symbols representing classes living in the Racket::Helpers
    #  namespace.
    def self.helper(*helpers)
      helper_modules = {}
      existing_helpers = settings.fetch(:helpers)
      if existing_helpers.nil?
        # No helpers has been loaded yet. Load the default helpers.
        existing_helpers = Application.settings.default_controller_helpers
        helper_modules.merge!(__load_helpers(existing_helpers))
      end
      # Load new helpers
      helpers.map!(&:to_sym)
      helpers.reject! { |helper| helper_modules.key?(helper) }
      helper_modules.merge!(__load_helpers(helpers))
      setting(:helpers, helper_modules)
    end

    # :nodoc:
    def self.inherited(klass)
      Application.settings.fetch(:last_added_controller).push(klass)
    end

    # Returns the settings associated with the current controller class.
    #
    # @return [Racket::Settings::Controller]
    def self.settings
      @settings ||= Settings::Controller.new(self)
    end

    # Creates/updates a setting for the current controller class.
    #
    # @param [Symbol] key
    # @param [Object] value
    # @return [nil]
    def self.setting(key, value)
      settings.store(key, value)
    end

    # Returns the settings for a controller instance.
    #
    # @return [Racket::Settings::Controller]
    def settings
      self.class.settings
    end

    # Redirects the client. After hooks are run.
    #
    # @param [String] target URL to redirect to
    # @param [Fixnum] status HTTP status to send
    # @return [Object]
    def redirect(target, status = 302)
      response.redirect(target, status)
      respond(response.status, response.headers, '')
    end

    # Redirects the client. After hooks are *NOT* run.
    #
    # @param [String] target URL to redirect to
    # @param [Fixnum] status HTTP status to send
    # @return [Object]
    def redirect!(target, status = 302)
      response.redirect(target, status)
      respond!(response.status, response.headers, '')
    end

    # Stop processing request and send a custom response. After calling this method, after hooks
    # (but no rendering) will be run.
    #
    # @param [Fixnum] status
    # @param [Hash] headers
    # @param [String] body
    def respond(status = 200, headers = {}, body = '')
      __run_hook(:after)
      respond!(status, headers, body)
    end

    # Stop processing request and send a custom response. After calling this method, no further
    # processing of the request is done.
    #
    # @param [Fixnum] status
    # @param [Hash] headers
    # @param [String] body
    def respond!(status = 200, headers = {}, body = '')
      throw :response, [status, headers, body]
    end

    # Calls hooks, action and renderer.
    #
    # @return [String]
    def __run
      __run_hook(:before)
      __run_action
      __run_hook(:after)
      Application.view_manager.render(self)
    end

    private

    def __run_action
      meth = method(racket.action)
      params = racket.params[0...meth.parameters.length]
      (racket.action_result = meth.call(*params)) && nil
    end

    def __run_hook(type)
      hooks = settings.fetch("#{type}_hooks".to_sym, {})
      blk = hooks.fetch(racket.action, nil)
      (instance_eval(&blk) if blk) && nil
    end
  end
end
