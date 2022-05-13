source "https://rubygems.org"

gemspec

group :maintenance, optional: true do
	gem 'bake-gem'
	gem 'bake-modernize'
	
	gem 'bake-github-pages'
	gem 'utopia-project'
end
