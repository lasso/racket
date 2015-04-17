require 'rake'

Gem::Specification.new do |s|
  s.name                  = 'racket'
  s.homepage              = 'https://github.com/lasso/racket'
  s.license               = 'GPL3'
  s.authors               = ['Lars Olsson']
  s.version               = '0.0.1'
  s.date                  = '2015-04-06'
  s.summary               = 'Racket - a tiny rack framework'
  s.description           = 'Racket - a tiny rack framework'
  s.files                 = FileList['lib/**/*.rb', '[A-Z]*'].to_a
  s.platform              = Gem::Platform::RUBY
  s.require_path          = 'lib'
  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency('http_router', '~> 0')
  s.add_dependency('rack', '~> 1.6')
  s.add_dependency('tilt', '~> 2.0')

  s.add_development_dependency('bacon', '~> 1.2')
end
