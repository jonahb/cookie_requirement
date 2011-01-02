# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = 'cookie_requirement'
  s.version     = '0.1.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ 'Jonah Burke' ]
  s.email       = [ 'jonah@jonahb.com' ]
  s.homepage    = ''
  s.summary     = 'Ensure cookies are enabled in a Rails app.'
  s.description = s.summary

  s.required_ruby_version = '~> 1.8.7'
  s.required_rubygems_version = '>= 1.3.5'

  s.files        = Dir.glob( 'lib/**/*' )
  s.require_path = 'lib'

  s.add_dependency 'actionpack', '~> 2.3.0'
  s.add_dependency 'activesupport', '~> 2.3.0'
end