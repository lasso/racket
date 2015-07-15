require 'rake'

mod = Module.new
mod.module_eval(
  File.read(
    File.join(File.dirname(__FILE__), 'lib', 'racket', 'version.rb')
  )
)
version = mod::Racket::Version.current
mod = nil

files = FileList['lib/**/*.rb'].to_a
files.concat(FileList['spec/**/*'].to_a)
files.concat(FileList['COPYING.AGPL', 'Rakefile', 'README.md'].to_a)

Gem::Specification.new do |s|
  s.name                  = 'racket-mvc'
  s.email                 = 'lasso@lassoweb.se'
  s.homepage              = 'https://github.com/lasso/racket'
  s.license               = 'GNU AFFERO GENERAL PUBLIC LICENSE, version 3'
  s.authors               = ['Lars Olsson']
  s.version               = version
  s.date                  = Time.now.strftime('%Y-%m-%d')
  s.summary               = 'Racket - The noisy Rack MVC framework'
  s.description           = 'Racket is a small MVC framework built on top of rack.'
  s.files                 = files
  s.platform              = Gem::Platform::RUBY
  s.require_path          = 'lib'
  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency('http_router', '~>0')
  s.add_dependency('rack', '~>1.6')
  s.add_dependency('tilt', '~>2.0')

  s.add_development_dependency('bacon', '~>1.2')
  s.add_development_dependency('codecov', '~>0.0.8')
  s.add_development_dependency('rack-test', '~>0.6')
  s.add_development_dependency('rake')
  s.add_development_dependency('simplecov', '~>0.10')
  s.add_development_dependency('yard')
end
