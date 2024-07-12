# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

require_relative 'source'
require_relative 'trie'

require_relative 'languages'

module Decode
	# A list of definitions organised for quick lookup and lexical enumeration.
	class Index
		# Initialize an empty index.
		def initialize(languages = Languages.all)
			@languages = languages
			
			@sources = {}
			@definitions = {}
			
			# This is essentially a prefix tree:
			@trie = Trie.new
		end
		
		def inspect
			"#<#{self.class} #{@definitions.size} definition(s)>"
		end

		alias to_s inspect

		# All supported languages for this index.
		# @attribute [Languages]
		attr :languages
		
		# All source files that have been parsed.
		# @attribute [Array(Source)]
		attr :sources
		
		# All definitions which have been parsed.
		# @attribute [Hash(String, Definition)]
		attr :definitions
		
		# A (prefix) trie of lexically scoped definitions.
		# @attribute [Trie]
		attr :trie
		
		# Updates the index by parsing the specified files.
		# All extracted definitions are merged into the existing index.
		#
		# @parameter paths [Array(String)] The source file paths.
		def update(paths)
			paths.each do |path|
				if source = @languages.source_for(path)
					@sources[path] = source
					
					source.definitions do |symbol|
						# $stderr.puts "Adding #{symbol.qualified_name} to #{symbol.lexical_path.join(' -> ')}"
						
						@definitions[symbol.qualified_name] = symbol
						@trie.insert(symbol.path, symbol)
					end
				end
			end
		end
		
		# Lookup the specified reference and return matching definitions.
		#
		# @parameter reference [Language::Reference] The reference to match.
		# @parameter relative_to [Definition] Lookup the reference relative to the scope of this definition.
		def lookup(reference, relative_to: nil)
			if reference.absolute? || relative_to.nil?
				lexical_path = []
			else
				lexical_path = relative_to.path.dup
			end
			
			path = reference.path
			
			while true
				node = @trie.lookup(lexical_path)
				
				if node.children[path.first]
					if target = node.lookup(path)
						return reference.best(target.values)
					else
						return nil
					end
				end
				
				break if lexical_path.empty?
				lexical_path.pop
			end
		end
	end
end
