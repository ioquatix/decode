
require_relative 'lib/decode/version'

Gem::Specification.new do |spec|
	spec.name = "decode"
	spec.version = Decode::VERSION
	spec.authors = ["Samuel Williams"]
	spec.email = ["samuel.williams@oriontransfer.co.nz"]
	
	spec.summary = "Code analysis for documentation generation."
	spec.homepage = "https://github.com/ioquatix/decode"
	spec.license = "MIT"
	
	spec.required_ruby_version = "~> 2.5"
	
	spec.files = Dir.glob('{lib,bake}/**/*', base: __dir__)
	spec.require_paths = ["lib"]
	
	spec.add_dependency "parser"
	
	spec.add_development_dependency 'build-files'
	spec.add_development_dependency 'bake-bundler'
	spec.add_development_dependency 'utopia-project'
	spec.add_development_dependency 'covered'
	spec.add_development_dependency 'bundler'
	spec.add_development_dependency 'rspec'
end
