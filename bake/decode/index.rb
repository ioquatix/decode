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
	
	missing = []
	public_count = 0
	documented_count = 0
	
	index.trie.traverse do |path, node, descend|
		public_definition = node.values.nil?
		
		node.values&.each do |definition|
			if definition.public?
				public_count += 1
				level = path.size
				
				if definition.comments.nil?
					missing << definition.qualified_name
				else
					documented_count += 1
				end
				
				public_definition = true
			end
		end
		
		# Don't descend into non-public definitions:
		if public_definition
			descend.call
		end
	end
	
	$stderr.puts "#{documented_count} definitions have documentation, out of #{public_count} public definitions."
	
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
