require './rake/utils.rb'

Gem::Specification.new do |s|
  s.name                  = 'racket-mvc'
  s.email                 = 'lasso@lassoweb.se'
  s.homepage              = 'https://github.com/lasso/racket'
  s.license               = 'AGPL-3.0'
  s.authors               = ['Lars Olsson']
  s.version               = racket_version
  s.date                  = Time.now.strftime('%Y-%m-%d')
  s.summary               = 'Racket - The noisy Rack MVC framework'
  s.description           = 'Racket is a small MVC framework built on top of rack.'
  s.files                 = racket_files
  s.platform              = Gem::Platform::RUBY
  s.require_path          = 'lib'
  s.required_ruby_version = '>= 2.2.0'

  s.add_dependency('http_router', '~>0.11')
  s.add_dependency('json', '~>2.0')
  s.add_dependency('rack', '~>1.6')
  s.add_dependency('racket-registry', '~>0.5')
  s.add_dependency('tilt', '~>2.0')

  s.add_development_dependency('bacon', '~>1.2')
  s.add_development_dependency('codecov', '~>0.1')
  s.add_development_dependency('rack-test', '~>0.7')
  s.add_development_dependency('rake', '~>12')
  s.add_development_dependency('sass', '~>3.5') # Needed by SASS plugin
  s.add_development_dependency('simplecov', '~>0.15')
  s.add_development_dependency('yard', '~>0.9')
end
