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
    attr_reader :utils

    def initialize(utils)
      @utils = utils
    end

    # @todo - Don't rely on Application'
    def self.__helper_cache
      Application.registry.helper_cache
    end

    # @todo - Don't rely on Application'
    def self.__logger
      Application.registry.application_logger
    end

    # Adds a hook to one or more actions.
    #
    # @param [Symbol] type
    # @param [Array] methods
    # @param [Proc] blk
    # @return [nil]
    def self.__register_hook(type, methods, blk)
      meths = public_instance_methods(false)
      meths &= methods.map(&:to_sym) unless methods.empty?
      __update_hooks("#{type}_hooks".to_sym, meths, blk)
      __logger.inform_dev("Adding #{type} hook #{blk} for actions #{meths} for #{self}.")
    end

    # Updates hooks in settings object.
    #
    # @param [Symbol] hook_key
    # @param [Array] meths
    # @param [Proc] blk
    # @return [nil]
    def self.__update_hooks(hook_key, meths, blk)
      hooks = settings.fetch(hook_key, {})
      meths.each { |meth| hooks[meth] = blk }
      setting(hook_key, hooks) && nil
    end

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
    # @return [nil]
    def self.helper(*helpers)
      helper_modules = {}
      unless settings.fetch(:helpers)
        # No helpers has been loaded yet. Load the default helpers first.
        helper_modules.merge!(
          __helper_cache.load_helpers(Application.settings.default_controller_helpers)
        )
      end
      # Load new helpers
      __load_helpers(helpers.map(&:to_sym), helper_modules)
    end

    # Loads new helpers and stores the list of helpers associated with the currenct controller
    # in the settings.
    #
    # @param [Array] helpers Requested helpers
    # @param [Array] helper_modules Helper modules already loaded
    # @return nil
    def self.__load_helpers(helpers, helper_modules)
      helpers.reject! { |helper| helper_modules.key?(helper) }
      helper_modules.merge!(__helper_cache.load_helpers(helpers))
      setting(:helpers, helper_modules) && nil
    end

    # :nodoc:
    def self.inherited(klass)
      settings.fetch(:last_added_controller).push(klass)
    end

    # Injects settings module
    #
    # @param [Module] mod
    def self.__inject_settings(mod)
      include mod
    end

    private_class_method :__helper_cache, :__load_helpers, :__register_hook, :__update_hooks

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
