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

module Decode
	class Trie
		class Node
			def initialize
				@values = nil
				@children = Hash.new
			end
			
			attr_accessor :values
			attr :children
			
			def lookup(path, index = 0)
				if index < path.size
					if child = @children[path[index]]
						return child.lookup(path, index+1)
					end
				else
					return self
				end
			end
			
			def traverse(path = [], &block)
				yield path, values if values
				
				@children.each do |name, node|
					node.traverse([*path, name], &block)
				end
			end
		end
		
		attr_accessor :value
		
		def initialize
			@root = Node.new
		end
		
		attr :root
		
		def insert(path, value)
			node = @root
			
			path.each do |key|
				node = (node.children[key] ||= Node.new)
			end
			
			(node.values ||= []) << value
		end
		
		def lookup(path)
			@root.lookup(path).values
		end
		
		# Given a base path, enumerate all paths under that.
		# @yield (path, values) pairs
		def each(path = [], &block)
			if node = @root.lookup(path)
				node.traverse(&block)
			end
		end
		
		def match(path, &block)
			@root.lookup(path)
		end
	end
end
