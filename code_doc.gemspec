# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'code_doc/version'

Gem::Specification.new do |gem|
  gem.name          = "code_doc"
  gem.version       = CodeDoc::VERSION
  gem.authors       = ["Jeff Gran"]
  gem.email         = ["jeff.gran@openlogic.com"]
  gem.description   = %q{Document your code using code.}
  gem.summary       = %q{Why invent a meta-language to define documentation using crazy comments, when we already have a perfectly good language called Ruby?}
  gem.homepage      = "http://github.com/jeffgran/code_doc"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'activesupport'
  gem.add_runtime_dependency 'sender'

  gem.add_development_dependency 'awesome_print'
  gem.add_development_dependency 'rspec'

end
