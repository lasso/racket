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
  module Utils
    # Namespace for application utilities
    module Application
      # Struct encapsulating a log message
      LogData = Struct.new(:message, :level)

      # Class for logging messages in the application.
      class Logger
        # Returns a service proc that can be used by the registry.
        #
        # @param  [Hash] _options (unused)
        # @return [Proc]
        def self.service(_options = {})
          lambda do |reg|
            settings = reg.application_settings
            new(settings.logger, settings.mode)
          end
        end

        def initialize(logger, mode)
          @logger = logger
          @in_dev_mode = (mode == :dev)
        end

        # Sends a message to the logger.
        #
        # @param [String] message
        # @param [Symbol] level
        # @return nil
        def inform_all(message, level = :info)
          inform(LogData.new(message, level))
        end

        # Sends a message to the logger, but only if we are running in dev mode.
        #
        # @param [String] message
        # @param [Symbol] level
        # @return nil
        def inform_dev(message, level = :debug)
          (inform(LogData.new(message, level)) if @in_dev_mode) && nil
        end

        private

        # Writes a message to the logger if there is one present.
        #
        # @param [LogData] logdata
        # @return nil
        def inform(logdata)
          (@logger.send(logdata.level, logdata.message) if @logger) && nil
        end
      end
    end
  end
end
