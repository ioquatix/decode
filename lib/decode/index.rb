# Copyright, 2020, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'source'
require_relative 'trie'

module Decode
	# A list of definitions organised for quick lookup and lexical enumeration.
	class Index
		# Initialize an empty index.
		def initialize
			@sources = {}
			@definitions = {}
			
			# This is essentially a prefix tree:
			@trie = Trie.new
		end
		
		# All source files that have been parsed.
		# @attr [Array(Source)]
		attr :sources
		
		# All definitions which have been parsed.
		# @attr [Array(Symbol)]
		attr :definitions
		
		# A (prefix) trie of lexically scoped definitions.
		# @attr [Trie]
		
		attr :trie
		
		# Updates the index by parsing the specified files.
		# All extracted definitions are merged into the existing index.
		#
		# @param paths [Array(String)] The source file paths.
		def update(paths)
			paths.each do |path|
				if source = Source.for?(path)
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
		# @param reference [Reference] The reference to match.
		# @param relative_to [Definition] Lookup the reference relative to the scope of this definition.
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
