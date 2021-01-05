# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'inferred_crumpets/version'

Gem::Specification.new do |spec|
  spec.name          = "inferred_crumpets"
  spec.version       = InferredCrumpets::VERSION
  spec.authors       = ["Grant Colegate"]
  spec.email         = ["support@travellink.com.au"]

  spec.summary       = "Automatic breadcrumbs for Rails."
  spec.description   = "Automatic breadcrumbs for Rails."
  spec.homepage      = "https://github.com/sealink/inferred_crumpets"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.6.0'

  spec.add_dependency "rails", ">= 6"
  spec.add_dependency "crumpet", ">= 0.3.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
