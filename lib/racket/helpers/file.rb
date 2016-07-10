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
  # Helpers module
  module Helpers
    # Helper module that handles files
    module File
      # Class for sending files.
      class Response
        def initialize(utils, file, options)
          @utils = utils
          @file = @utils.build_path(file)
          @options = options
          @response = Racket::Response.new
          build
        end

        # Returns the current object as a Rack response array.
        #
        # @return [Array]
        def to_a
          @response.to_a
        end

        private

        def build
          if @utils.file_readable?(@file) then build_success
          else build_failure
          end
        end

        def build_failure
          @response.status = 404
          @response.headers['Content-Type'] = 'text/plain'
          @response.write(Rack::Utils::HTTP_STATUS_CODES[@response.status])
        end

        def build_success
          @response.status = 200
          set_mime_type
          set_content_disposition
          @response.write(::File.read(@file))
        end

        def set_content_disposition
          # Set Content-Disposition (and a file name) if the file should be downloaded
          # instead of displayed inline.
          return unless @options.fetch(:download, false)
          content_disposition = 'attachment'
          filename = @options.fetch(:filename, nil).to_s
          content_disposition << format('; filename="%s"', filename) unless filename.empty?
          @response.headers['Content-Disposition'] = content_disposition
        end

        def set_mime_type
          mime_type = @options.fetch(:mime_type, nil)
          # Calculate MIME type if it was not already specified.
          mime_type = Rack::Mime.mime_type(::File.extname(@file)) unless mime_type
          @response.headers['Content-Type'] = mime_type
        end
      end

      # Sends the contents of a file to the client.
      #
      # @param [String] file
      # @param [Hash] options
      # @return [Array]
      def send_file(file, options = {})
        response = Response.new(@utils, file, options).to_a
        respond!(*response)
      end
    end
  end
end
