# -*- encoding: utf-8 -*-
require File.expand_path('../lib/grandprix/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Rafael de F. Ferreira"]
  gem.email         = ["public@rafaelferreira.net"]
  gem.description   = %q{Deploy assistant.}
  gem.summary       = %q{Deploy assistant}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "grandprix"
  gem.require_paths = ["lib"]
  gem.version       = File.read("version").chomp
end
