# frozen_string_literal: true

require_relative "lib/decode/version"

Gem::Specification.new do |spec|
	spec.name = "decode"
	spec.version = Decode::VERSION
	
	spec.summary = "Code analysis for documentation generation."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/ioquatix/decode"
	
	spec.metadata = {
		"documentation_uri" => "https://ioquatix.github.io/decode/",
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
		"source_code_uri" => "https://github.com/ioquatix/decode.git",
	}
	
	spec.files = Dir.glob(["{bake,context,lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.2"
	
	spec.add_dependency "prism"
	spec.add_development_dependency "rbs"
end
