# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'virtus/mapper/version'

Gem::Specification.new do |spec|
  spec.name          = "virtus-mapper"
  spec.version       = Virtus::Mapper::VERSION
  spec.authors       = ["RentPath"]
  spec.email         = ["tstankus@rentpath.com", "tcampbell@rentpath.com"]
  spec.summary       = %q{Mapper for Virtus attributes}
  spec.description   = %q{Mapper for Virtus attributes. See README.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'virtus', '~> 1.0', '>= 1.0.3'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
