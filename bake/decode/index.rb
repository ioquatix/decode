# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020, by Samuel Williams.

# Process the given source root and report on comment coverage.
# @parameter root [String] The root path to index.
def coverage(root)
	require 'build/files/glob'
	require 'decode/index'
	
	paths = Build::Files::Path.expand(root).glob("**/*")
	
	index = Decode::Index.new
	index.update(paths)
	
	total = 0
	documented = 0
	
	index.definitions.each do |name, definition|
		total += 1
		
		if comments = definition.comments
			documented += 1
		else
			$stderr.puts "#{name}"
		end
	end
	
	$stderr.puts "#{documented}/#{total} definitions have documentation."
end
