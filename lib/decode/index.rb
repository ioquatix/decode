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
	class Index
		def initialize
			@sources = {}
			@symbols = {}
			
			# This is essentially a prefix tree:
			@trie = Trie.new
		end
		
		attr :sources
		attr :symbols
		
		attr :trie
		
		def update(paths)
			paths.each do |path|
				source = Source.new(path)
				@sources[path.relative_path] = Source.new(path)
				
				source.parse do |definition|
					@symbols[definition.qualified_name] = definition
					
					@trie.insert(definition.lexical_path, definition)
				end
			end
		end
		
		def lookup(reference, relative_to: nil)
			if reference.absolute? || relative_to.nil?
				lexical_path = []
			else
				lexical_path = relative_to.lexical_path
			end
			
			path = reference.path
			
			while true
				node = @trie.match(lexical_path)
				
				if node.children[path.first]
					if target = node.lookup(path)
						if reference.kind
							return target.values.select{|symbol| symbol.kind == reference.kind}
						else
							return target.values
						end
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
