require 'simplecov'
require 'stringio'

SimpleCov.start do
  add_filter 'spec'
  if ENV['CI'] == 'true'
    require 'codecov'
    formatter = SimpleCov::Formatter::Codecov
  end
end

TEST_DEFAULT_APP_DIR = File.absolute_path(File.join(File.dirname(__FILE__), 'test_default_app'))
TEST_CUSTOM_APP_DIR = File.absolute_path(File.join(File.dirname(__FILE__), 'test_custom_app'))

require 'racket'
require 'rack/test'
require 'bacon'

Dir.chdir(TEST_DEFAULT_APP_DIR) { require_relative '_default.rb' }

Racket::Application.class_eval { @current = nil }

Dir.chdir(TEST_CUSTOM_APP_DIR) { require_relative '_custom.rb' }
