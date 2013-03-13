# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'joinable_array/version'

Gem::Specification.new do |spec|
  spec.name          = "joinable_array"
  spec.version       = JoinableArray::VERSION
  spec.authors       = ["Steven Noble"]
  spec.email         = ["steven.noble@gmail.com"]
  spec.description   = %q{A way to do sql style joins with Array}
  spec.summary       = %q{joinable arrays}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
