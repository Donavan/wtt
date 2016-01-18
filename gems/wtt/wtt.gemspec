# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wtt/core/version'

Gem::Specification.new do |spec|
  spec.name          = 'wtt-core'
  spec.version       = WTT::Core::VERSION
  spec.authors       = ['Donavan Stanley']
  spec.email         = ['dstanley@covermymeds.com']

  spec.summary       = 'Core functionality for What to Test'
  spec.homepage      = 'https://github.com/covermymeds/wtt'


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'gem-release'
  spec.add_dependency 'rake', '~> 10.0'
  spec.add_dependency 'rugged', '~> 0.23'
end
