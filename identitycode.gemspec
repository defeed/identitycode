# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'identity_code/version'

Gem::Specification.new do |spec|
  spec.name          = "identitycode"
  spec.version       = IdentityCode::VERSION
  spec.authors       = ["Artem Pakk"]
  spec.email         = ["apakk@me.com"]

  spec.summary       = %q{Ruby gem to generate and validate Estonian identity codes}
  spec.description   = %q{Ruby gem to generate and validate Estonian identity codes}
  spec.homepage      = "https://github.com/defeed/identitycode"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
