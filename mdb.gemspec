# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mdb/version"

Gem::Specification.new do |spec|
  spec.name          = "mdb"
  spec.version       = Mdb::VERSION
  spec.authors       = ["Robert Lail"]
  spec.email         = ["robert.lail@cph.org"]

  spec.description   = %q{A library for reading Microsoft Access databases}
  spec.summary       = %q{Wraps mdb-tools for reading and Microsoft Access databases (MDB)}
  spec.homepage      = "https://github.com/cph/mdb"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rails", ">= 3.2.0", "< 4.1.0"
  spec.add_development_dependency "shoulda-context"
  spec.add_development_dependency "turn"
  spec.add_development_dependency "pry"
end
