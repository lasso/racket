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
      # Sends the contents of a file to the client.
      #
      # @param [String] file
      # @param [Hash] options
      # @return [Array]
      def send_file(file, options = {})
        file = Utils.build_path(file)
        _send_file_check_file_readable(file)
        headers = {}
        mime_type = options.fetch(:mime_type, nil)
        # Calculate MIME type if it was not already specified.
        mime_type = Rack::Mime.mime_type(::File.extname(file)) unless mime_type
        headers['Content-Type'] = mime_type
        # Set Content-Disposition (and a file name) if the file should be downloaded
        # instead of displayed inline.
        _send_file_set_content_disposition(options, headers)
        # Send response
        respond!(200, headers, ::File.read(file))
      end

      private

      def _send_file_check_file_readable(file)
        # Respond with a 404 Not Found if the file cannot be read.
        respond!(
          404,
          { 'Content-Type' => 'text/plain' },
          Rack::Utils::HTTP_STATUS_CODES[404]
        ) unless Utils.file_readable?(file)
      end

      def _send_file_set_content_disposition(options, headers)
        return unless options.fetch(:download, false)
        filename = options.fetch(:filename, nil).to_s
        headers['Content-Disposition'] = 'attachment'
        headers['Content-Disposition'] << format('; filename="%s"', filename) unless filename.empty?
      end
    end
  end
end
