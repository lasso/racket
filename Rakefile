require 'rubygems'
require 'bundler/setup'

desc "Run bacon tests"
task default: [:test]

desc "Build racket-mvc gem"
task :build_gem do
  exec 'gem build racket.gemspec'
end

desc "Build yard docs"
task :doc do
  exec 'yard'
end

desc "Show list of undocumented modules/classes/methods"
task :nodoc do
  exec 'yard stats --list-undoc'
end

desc "Publish racket-mvc gem"
task publish_gem: [:build_gem] do
  exec 'gem push racket-mvc.gem'
end

desc "Run bacon tests"
task :test do
  exec 'bacon spec/racket.rb'
end
