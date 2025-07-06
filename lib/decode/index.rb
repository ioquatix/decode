# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "source"
require_relative "trie"

require_relative "languages"

module Decode
	# Represents a list of definitions organised for quick lookup and lexical enumeration.
	class Index
		# Initialize an empty index.
		# @parameter languages [Languages] The languages to support in this index.
		def initialize(languages = Languages.all)
			# Initialize with supported languages:
			@languages = languages
			
			# Initialize storage for sources and definitions:
			@sources = {}
			@definitions = {}
			
			# Create a prefix tree for efficient lookups:
			@trie = Trie.new
		end
		
		# Generate a string representation of this index.
		# @returns [String] A formatted string showing the number of definitions.
		def inspect
			"#<#{self.class} #{@definitions.size} definition(s)>"
		end

		alias to_s inspect

		# All supported languages for this index.
		# @attribute [Languages] The languages this index can parse.
		attr :languages
		
		# All source files that have been parsed.
		# @attribute [Hash(String, Source)] A mapping of file paths to source objects.
		attr :sources
		
		# All definitions which have been parsed.
		# @attribute [Hash(String, Definition)] A mapping of qualified names to definitions.
		attr :definitions
		
		# A (prefix) trie of lexically scoped definitions.
		# @attribute [Trie] The trie structure for efficient lookups.
		attr :trie
		
		# Updates the index by parsing the specified files.
		# All extracted definitions are merged into the existing index.
		# @parameter paths [Array(String)] The source file paths to parse and index.
		def update(paths)
			paths.each do |path|
				if source = @languages.source_for(path)
					# Store the source file:
					@sources[path] = source
					
					# Extract and index all definitions:
					source.definitions do |symbol|
						# $stderr.puts "Adding #{symbol.qualified_name} to #{symbol.lexical_path.join(' -> ')}"
						
						# Add to definitions lookup:
						@definitions[symbol.qualified_name] = symbol
						
						# Add to trie for hierarchical lookup:
						@trie.insert(symbol.full_path, symbol)
					end
				end
			end
		end
		
		# Lookup the specified reference and return matching definitions.
		# @parameter reference [Language::Reference] The reference to match.
		# @parameter relative_to [Definition] Lookup the reference relative to the scope of this definition.
		# @returns [Definition | Nil] The best matching definition, or nil if not found.
		def lookup(reference, relative_to: nil)
			if reference.absolute? || relative_to.nil?
				# Start from root scope:
				lexical_path = []
			else
				# Start from the given definition's scope:
				lexical_path = relative_to.full_path.dup
			end
			
			path = reference.path
			
			while true
				# Get the current scope node:
				node = @trie.lookup(lexical_path)
				
				if node.children[path.first]
					if target = node.lookup(path)
						# Return the best matching definition:
						return reference.best(target.values)
					else
						return nil
					end
				end
				
				# Move up one scope level:
				break if lexical_path.empty?
				lexical_path.pop
			end
		end
	end
end
