# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'meteorlog/version'

Gem::Specification.new do |spec|
  spec.name          = 'meteorlog'
  spec.version       = Meteorlog::VERSION
  spec.authors       = ['Genki Sugawara']
  spec.email         = ['sgwr_dts@yahoo.co.jp']
  spec.description   = "Meteorlog is a tool to manage CloudWatch Logs. It defines the state of CloudWatch Logs using DSL, and updates CloudWatch Logs according to DSL."
  spec.summary       = "Meteorlog is a tool to manage CloudWatch Logs."
  spec.homepage      = 'https://github.com/winebarrel/meteorlog'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk-core', '>= 2.0.0.rc8'
  spec.add_dependency "json"
  spec.add_dependency "term-ansicolor"
  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
end
