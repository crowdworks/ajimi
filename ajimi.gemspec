# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ajimi/version'

Gem::Specification.new do |spec|
  spec.name          = "ajimi"
  spec.version       = Ajimi::VERSION
  spec.authors       = ["Masayuki Morita"]
  spec.email         = ["masayuki.morita@crowdworks.co.jp"]

  spec.summary       = %q{server diff tool}
  spec.description   = %q{Ajimi is a server diff tool which compares the difference between any two server's files. It helps you to find the configuration difference in a large number of files.}
  spec.homepage      = "https://github.com/crowdworks/ajimi"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "net-ssh", "~> 2.0"
  spec.add_runtime_dependency "diff-lcs"
  spec.add_runtime_dependency "thor"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "guard-rspec", "~> 4.0"
  spec.add_development_dependency "terminal-notifier-guard"

end
