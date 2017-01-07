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
  spec.homepage      = 'https://github.com/isolo/version-manager'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split("\n")
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.bindir        = 'exe'
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_dependency 'docopt', '~> 0.5'
  spec.add_dependency 'inquirer', '~> 0.2'
  spec.add_dependency 'git', '~> 1.3'
end
