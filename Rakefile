require 'rubygems'
require 'bundler/setup'

task default: %w[test]

task :build_gem do
  exec 'gem build racket.gemspec'
end

task :doc do
  exec 'yard'
end

task :nodoc do
  exec 'yard stats --list-undoc'
end

task :test do
  exec 'bacon spec/racket.rb'
end
