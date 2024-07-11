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
	
	total_count = 0
	public_count = 0
	documented_count = 0
	
	missing = []
	
	index.definitions.each do |name, definition|
		total_count += 1
		
		if definition.public?
			public_count += 1
			
			if comments = definition.comments
				documented_count += 1
			elsif definition.public?
				missing << name
			end
		end
	end
	
	$stderr.puts "#{documented_count} definitions have documentation, out of #{public_count} public definitions and #{total_count} total definitions."
	
	if documented_count < public_count
		$stderr.puts nil, "Missing documentation for:"
		missing.each do |name|
			$stderr.puts "- #{name}"
		end
		
		raise RuntimeError, "Insufficient documentation!"
	end
end

# Process the given source root and report on symbols.
# @parameter root [String] The root path to index.
def symbols(root)
	require 'build/files/glob'
	require 'decode/index'
	
	paths = Build::Files::Path.expand(root).glob("**/*")
	
	index = Decode::Index.new
	index.update(paths)
	
	index.trie.traverse do |path, node, descend|
		level = path.size
		puts "#{"  " * level}#{path.inspect} -> #{node.values.inspect}"
		
		if path.any?
			puts "#{"  " * level}#{path.join("::")}"
		end
		
		descend.call
	end
end

# Print documentation for all definitions.
# @parameter root [String] The root path to index.
def documentation(root)
	require 'build/files/glob'
	require 'decode/index'
	
	paths = Build::Files::Path.expand(root).glob("**/*")
	
	index = Decode::Index.new
	index.update(paths)
	
	index.definitions.each do |name, definition|
		comments = definition.comments
		
		if comments
			puts "## `#{name}`"
			puts
			puts comments
			puts
		end
	end
end
