# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version-manager/version'

Gem::Specification.new do |spec|
  spec.name          = 'version-manager'
  spec.version       = VersionManager::VERSION
  spec.authors       = ['isolo']
  spec.email         = ['ilya.i.solo@gmail.com']

  spec.summary       = 'Versioning lib (with Git support)'
  spec.homepage      = 'version-manager'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split('\x0').reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   << 'manver'
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'docopt.rb', '~> 1.3.0'
  spec.add_development_dependency 'git', '~> 1.3.0'
end
