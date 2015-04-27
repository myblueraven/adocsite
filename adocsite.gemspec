# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'adocsite/version'

Gem::Specification.new do |spec|
  spec.name          = "adocsite"
  spec.version       = Adocsite::VERSION
  spec.authors       = ["Bruce Brennan"]
  spec.email         = ["bb@myblueraven.com"]
  spec.summary       = %q{Static site generator.}
  spec.description   = %q{Very simple static site generator for asciidoc documents.}
  spec.homepage      = "https://github.com/myblueraven/adocsite#adocsite"
  spec.license       = "GPL v3"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'haml'
  spec.add_dependency 'asciidoctor'
  spec.add_dependency 'tilt'
  spec.add_dependency 'commander'
  spec.add_dependency 'rubypress'
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'terminal-table'
  spec.add_dependency 'mime-types'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
