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

def racket_version
  mod = Module.new
  mod.module_eval(
    File.read(
      File.join(File.dirname(File.dirname(__FILE__)), 'lib', 'racket', 'version.rb')
    )
  )
  mod::Racket::Version.current
end

def racket_files
  Dir.chdir(File.dirname(File.dirname(__FILE__))) do
    files = FileList['lib/**/*.rb'].to_a
    files.concat(FileList['rake/**/*'].to_a)
    files.concat(FileList['spec/**/*'].to_a)
    files.concat(FileList['COPYING.AGPL', 'Rakefile', 'README.md'].to_a)
  end
end
