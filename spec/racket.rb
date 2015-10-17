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

TEST_DIR = File.absolute_path(File.dirname(__FILE__))
TEST_DEFAULT_APP_DIR = File.join(TEST_DIR, 'test_default_app')
TEST_CUSTOM_APP_DIR = File.join(TEST_DIR, 'test_custom_app')

require 'racket'

# Make sure some files that are loaded dynamically get coverage as well.
require 'racket/helpers/file.rb'

require 'rack/test'
require 'bacon'

# Method tests should always be run first.
require File.join(TEST_DIR, '_request.rb')

# Application tests.
suites = [
  -> { Dir.chdir(TEST_DEFAULT_APP_DIR) { require File.join(TEST_DIR, '_default.rb') } },
  -> { Dir.chdir(TEST_CUSTOM_APP_DIR) { require File.join(TEST_DIR, '_custom.rb') } }
]

# Leave off randomization for now. Sessions does not seem to be reset correctly between suites!
# suites.shuffle!

# Run application tests.
suites.each do |suite|
  Racket::Application.reset!
  suite.call
end

# Invalid application test should always be run last.
require File.join(TEST_DIR, '_invalid.rb')
