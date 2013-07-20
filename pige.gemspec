# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pige/version'

Gem::Specification.new do |gem|
  gem.name          = "pige"
  gem.version       = Pige::VERSION
  gem.authors       = ["Alban Peignier", "Florent Peyraud"]
  gem.email         = ["alban@tryphon.eu", "florent@tryphon.eu"]
  gem.description   = %q{Manage internal resources of Tryphon Pige}
  gem.summary       = %q{Pige management (record, upload, ...)}
  gem.homepage      = "http://projects.tryphon.eu/projects/pige"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  # TagLib 0.5.0 requires tagc0 1.7
  gem.add_runtime_dependency "taglib-ruby", "~> 0.4.0"
  gem.add_runtime_dependency "activesupport", "< 4"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "guard"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "guard-bundler"
  gem.add_development_dependency "flog"
  gem.add_development_dependency "flay"
  gem.add_development_dependency "rdoc"
end
