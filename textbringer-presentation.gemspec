# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'textbringer/presentation/version'

Gem::Specification.new do |spec|
  spec.name          = "textbringer-presentation"
  spec.version       = Textbringer::Presentation::VERSION
  spec.authors       = ["Shugo Maeda"]
  spec.email         = ["shugo@ruby-lang.org"]

  spec.summary       = "Presentation mode for Textbringer."
  spec.description   = "Presentation mode for Textbringer."
  spec.homepage      = "https://github.com/shugo/textbringer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "textbringer"
  spec.add_runtime_dependency "commonmarker"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "codecov"
  spec.add_development_dependency "bundler-audit"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-shell"
  spec.add_development_dependency "ripper-tags"
end
