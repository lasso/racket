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
  module Utils
    # Utility functions for routing.
    module Helpers
      # Cache for helpers, ensuring that helpers get loaded exactly once.
      class HelperCache
        def initialize(helper_dir)
          @helper_dir = helper_dir
          @helpers = {}
        end

        # Loads helper files and return the loadad modules as a hash. Any helper files that
        # cannot be loaded are excluded from the result.
        #
        # @param [Array] helpers An array of symbols
        # @return [Hash]
        def load_helpers(helpers)
          helper_modules = {}
          helpers.each do |helper|
            helper_module = load_helper(helper)
            helper_modules[helper] = helper_module if helper_module
          end
          helper_modules
        end

        private

        def load_helper(helper)
          return @helpers[helper] if @helpers.key?(helper)
          helper_module = load_helper_file(helper)
          @helpers[helper] = helper_module if helper_module
        end

        def load_helper_file(helper)
          require_helper_file(helper)
          self.class.load_helper_module(helper)
        end

        def require_helper_file(helper)
          loaded = Utils.safe_require("racket/helpers/#{helper}")
          Utils.safe_require(Utils.build_path(@helper_dir, helper).to_s) if !loaded && @helper_dir
        end

        def self.load_helper_module(helper)
          helper_module = nil
          Utils.run_block(NameError) do
            helper_module =
              Racket::Helpers.const_get(helper.to_s.split('_').collect(&:capitalize).join.to_sym)
            ::Racket::Application.inform_dev("Loaded helper module #{helper.inspect}.")
          end
          helper_module
        end
      end

      # Applies helpers to a controller class by including the modules in the class.
      #
      # @param [Class] klass
      def apply_helpers(klass)
        klass.helper unless klass.settings.fetch(:helpers) # Makes sure default helpers are loaded.
        __apply_helpers(klass)
        nil
      end

      def __apply_helpers(klass)
        klass.settings.fetch(:helpers).reverse_each do |pair|
          helper_key, helper = pair
          ::Racket::Application.inform_dev(
            "Adding helper module #{helper_key.inspect} to #{klass}"
          )
          klass.send(:include, helper)
        end
      end

      # @TODO: Remove when Racket::Utils stops being a singleton
      extend self
    end
  end
end
