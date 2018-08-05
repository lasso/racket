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

require_relative 'base.rb'
require_relative 'defaults.rb'

module Racket
  module Settings
    # Class for storing application settings.
    class Application < Base
      @defaults = Defaults.application_defaults

      %i[
        default_action default_content_type default_controller_helpers
        default_layout default_view logger middleware mode plugins
        session_handler root_dir template_settings warmup_urls
      ].each { |key| setting(key) }

      # Returns a service proc that can be used by the registry.
      #
      # @param  [Hash] options
      # @return [Proc]
      def self.service(options = {})
        ->(reg) { new(reg.utils, options) }
      end

      def initialize(utils, defaults = {})
        @utils = utils
        super(defaults)
      end

      # Creates a directory setting with a default value.
      #
      # @param [Symbol] symbol
      # @param [String] directory
      # @return [nil]
      def self.directory_setting(symbol, directory)
        define_directory_method(symbol, "@#{symbol}".to_sym, directory)
        attr_writer(symbol) && nil
      end

      def self.define_directory_method(symbol, ivar, directory)
        define_method symbol do
          instance_variable_set(ivar, directory) unless instance_variables.include?(ivar)
          return nil unless (value = instance_variable_get(ivar))
          @utils.build_path(value)
        end
      end

      {
        controller_dir: 'controllers',
        helper_dir: 'helpers',
        layout_dir: 'layouts',
        public_dir: 'public',
        view_dir: 'views'
      }.each_pair { |key, value| directory_setting(key, value) }

      private_class_method :define_directory_method
    end
  end
end
