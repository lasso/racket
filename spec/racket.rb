require 'simplecov'
require 'stringio'
require 'tilt/erb'

SimpleCov.start do
  add_filter 'spec'
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

TEST_DEFAULT_APP_DIR = File.absolute_path(File.join(File.dirname(__FILE__), 'test_default_app'))
TEST_CUSTOM_APP_DIR = File.absolute_path(File.join(File.dirname(__FILE__), 'test_custom_app'))

require 'racket'

# Make sure some files that are loaded dynamically get coverage as well.
require 'racket/helpers/file.rb'

require 'rack/test'
require 'bacon'

require_relative '_request.rb'

Dir.chdir(TEST_DEFAULT_APP_DIR) { require_relative '_default.rb' }
Dir.chdir(TEST_CUSTOM_APP_DIR) { require_relative '_custom.rb' }

require_relative '_invalid.rb'
