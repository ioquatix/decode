# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

source "https://rubygems.org"

gemspec

group :maintenance, optional: true do
	gem "bake-gem"
	gem "bake-modernize"
	
	gem "bake-github-pages"
	gem "utopia-project"
end

group :test do
	gem "sus"
	gem "covered"
	gem "rubocop"
	
	gem "bake-test"
	gem "bake-test-external"
	
	gem "build-files"
end
