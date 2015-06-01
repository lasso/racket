require 'simplecov'
require 'stringio'

SimpleCov.start do
  add_filter 'spec/test_default_app'
  add_filter 'spec/test_custom_app'
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

TEST_DEFAULT_APP_DIR = File.absolute_path(File.join(File.dirname(__FILE__), 'test_default_app'))
TEST_CUSTOM_APP_DIR = File.absolute_path(File.join(File.dirname(__FILE__), 'test_custom_app'))

require 'racket'
require 'rack/test'
require 'bacon'

Dir.chdir(TEST_DEFAULT_APP_DIR) { require_relative '_default.rb' }

Racket::Application.class_eval { @current = nil }

Dir.chdir(TEST_CUSTOM_APP_DIR) { require_relative '_custom.rb' }
