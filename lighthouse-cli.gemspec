# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lighthouse/cli/version'

Gem::Specification.new do |spec|
  spec.name          = "lighthouse-cli"
  spec.version       = Lighthouse::CLI::VERSION
  spec.authors       = ["Chris Holmes"]
  spec.email         = ["tochrisholmes@gmail.com"]
  spec.description   = %q{A lightweight and simple CLI for interacting with Lighthouse.}
  spec.summary       = %q{This is wrapper around the lightouse-api gem. Show, list and update tickets without leaving the command line.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = ["lighthouse"]
  spec.require_paths = ["lib"]

  spec.add_dependency "lighthouse-api", "~> 2.0"

  spec.add_development_dependency "bundler", "~> 1.2"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "addressable"
end
