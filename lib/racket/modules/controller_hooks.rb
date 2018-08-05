# Racket - The noisy Rack MVC framework
# Copyright (C) 2015-2018  Lars Olsson <lasso@lassoweb.se>
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
  # Collects modules that are included by the core classes.
  module Modules
    # Hook methods used by the Controller class.
    module ControllerHooks
      # Adds a hook to one or more actions.
      #
      # @param [Symbol] type
      # @param [Array] actions
      # @param [Proc] blk
      # @return [nil]
      def __register_hook(type, actions, blk)
        actions = Racket::Utils::Routing::Dispatcher.action_symbol_list(actions)
        __update_hooks("#{type}_hooks".to_sym, actions, blk)
        actions_str = actions == ['*'.to_sym] ? 'all actions' : "actions #{actions}"
        context.logger.inform_dev("Adding #{type} hook #{blk} for #{actions_str} for #{self}.")
      end

      # Updates hooks in settings object.
      #
      # @param [Symbol] hook_key
      # @param [Array] actions
      # @param [Proc] blk
      # @return [nil]
      def __update_hooks(hook_key, actions, blk)
        hooks = settings.fetch(hook_key, {})
        actions.each { |action| hooks[action] = blk }
        setting(hook_key, hooks) && nil
      end

      # Adds a before hook to one or more actions. Actions should be given as a list of symbols.
      # If no symbols are provided, *all* actions on the controller is affected.
      #
      # @param [Array] actions
      # @return [nil]
      def after(*actions, &blk)
        __register_hook(:after, actions, blk) if block_given?
      end

      # Adds an after hook to one or more actions. Actions should be given as a list of symbols.
      # If no symbols are provided, *all* actions on the controller is affected.
      #
      # @param [Array] actions
      # @return [nil]
      def before(*actions, &blk)
        __register_hook(:before, actions, blk) if block_given?
      end
    end
  end
end
