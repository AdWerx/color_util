# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'color_util/version'

Gem::Specification.new do |gem|
  gem.name          = "color_util"
  gem.version       = ColorUtil::VERSION
  gem.authors       = ["Steven Hilton"]
  gem.email         = ["mshiltonj@gmail.com"]
  gem.description   = %q{Simple color utility for reverbnation}
  gem.summary       = %q{Simple color utility for reverbnation}
  gem.homepage      = ""
  gem.add_dependency('rmagick')
  gem.add_development_dependency('rspec')
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
