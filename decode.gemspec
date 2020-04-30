
require_relative 'lib/decode/version'

Gem::Specification.new do |spec|
	spec.name = "decode"
	spec.version = Decode::VERSION
	spec.authors = ["Samuel Williams"]
	spec.email = ["samuel.williams@oriontransfer.co.nz"]
	
	spec.summary = "Code analysis for documentation generation."
	spec.homepage = "https://github.com/ioquatix/decode"
	spec.license = "MIT"
	
	spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")
	
	# Specify which files should be added to the gem when it is released.
	# The `git ls-files -z` loads the files in the RubyGem that have been added into git.
	spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
		`git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
	end
	
	spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
	spec.require_paths = ["lib"]
	
	spec.add_dependency 'build-files'
	spec.add_dependency "parser"
	
	spec.add_development_dependency 'bake-bundler'
	
	spec.add_development_dependency 'utopia-wiki'
	spec.add_development_dependency 'covered'
	spec.add_development_dependency 'bundler'
	spec.add_development_dependency 'rspec'
end
