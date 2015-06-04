task default: %w[test]

task :doc do
  exec 'yard'
end

task :nodoc do
  exec 'yard stats --list-undoc'
end

task :test do
  exec 'bacon spec/racket.rb'
end
