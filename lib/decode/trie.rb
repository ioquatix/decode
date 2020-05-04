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
	# A prefix-trie data structure for fast lexical lookups.
	class Trie
		# A single node in the trie.
		class Node
			def initialize
				@values = nil
				@children = Hash.new
			end
			
			# A mutable array of all values that terminate at this node.
			# @attr [Array]
			attr_accessor :values
			
			# A hash table of all children nodes, indexed by name.
			# @attr [Hash(String, Node)]
			attr :children
			
			# Look up a lexical path starting at this node.
			#
			# @param path [Array(String)] The path to resolve.
			# @return [Node | Nil]
			def lookup(path, index = 0)
				if index < path.size
					if child = @children[path[index]]
						return child.lookup(path, index+1)
					end
				else
					return self
				end
			end
			
			# Traverse the trie from this node.
			# Invoke `descend.call` to traverse the children of the current node.
			#
			# @param path [Array(String)] The current lexical path.
			#
			# @block `{|path, node, descend| descend.call}`
			# @yield path [Array(String)] The current lexical path.
			# @yield node [Node] The current node which is being traversed.
			# @yield descend [Proc] The recursive method for traversing children.
			def traverse(path = [], &block)
				yield(path, self, ->{
					@children.each do |name, node|
						node.traverse([*path, name], &block)
					end
				})
			end
		end
		
		# Initialize an empty trie.
		def initialize
			@root = Node.new
		end
		
		# The root of the trie.
		# @attr [Node]
		attr :root
		
		# Insert the specified value at the given path into the trie.
		# @param path [Array(String)] The lexical path where the value will be inserted.
		# @param value [Object] The value to insert.
		def insert(path, value)
			node = @root
			
			path.each do |key|
				node = (node.children[key] ||= Node.new)
			end
			
			(node.values ||= []) << value
		end
		
		# Lookup the values at the specified path.
		#
		# @param path [Array(String)] The lexical path which contains the values.
		# @return [Array(Object) | Nil] The values that existed (or not) at the specified path.
		def lookup(path)
			@root.lookup(path)
		end
		
		# Enumerate all lexical scopes under the specified path.
		#
		# @block `{|path, values| ...}`
		# @yield path [Array(String)] The lexical path.
		# @yield values [Array(Object)] The values that exist at the given path.
		def each(path = [], &block)
			if node = @root.lookup(path)
				node.traverse do |path, node, descend|
					yield path, node.values
					
					descend.call
				end
			end
		end
		
		# Traverse the trie.
		# See {Node:traverse} for details.
		def traverse(path = [], &block)
			if node = @root.lookup(path)
				node.traverse(&block)
			end
		end
	end
end
