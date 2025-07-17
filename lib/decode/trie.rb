# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2025, by Samuel Williams.

require_relative "source"

module Decode
	# Represents a prefix-trie data structure for fast lexical lookups.
	class Trie
		# Represents a single node in the trie.
		class Node
			# Initialize a new trie node.
			def initialize
				@values = nil
				@children = Hash.new
			end
			
			# Generate a string representation of this node.
			# @returns [String] A formatted string showing the number of children.
			def inspect
				"#<#{self.class} #{@children.size} children>"
			end
			
			# Generate a string representation of the node.
			alias to_s inspect
			
			# A mutable array of all values that terminate at this node.
			# @attribute [Array | Nil] The values stored at this node, or nil if no values.
			attr_accessor :values
			
			# A hash table of all children nodes, indexed by name.
			# @attribute [Hash(String, Node)] Child nodes indexed by their path component.
			attr :children
			
			# Look up a lexical path starting at this node.
			# @parameter path [Array(String)] The path to resolve.
			# @parameter index [Integer] The current index in the path (used for recursion).
			# @returns [Node | Nil] The node at the specified path, or nil if not found.
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
			# @parameter path [Array(String)] The current lexical path.
			# @yields {|path, node, descend| ...} Called for each node during traversal.
			#   @parameter path [Array(String)] The current lexical path.
			#   @parameter node [Node] The current node which is being traversed.
			#   @parameter descend [Proc] The recursive method for traversing children.
			def traverse(path = [], &block)
				descend = lambda do
					@children.each do |name, node|
						node.traverse([*path, name], &block)
					end
				end
				
				yield(path, self, descend)
			end
		end
		
		# Initialize an empty trie.
		def initialize
			@root = Node.new
		end
		
		# The root of the trie.
		# @attribute [Node] The root node of the trie structure.
		attr :root
		
		# Insert the specified value at the given path into the trie.
		# @parameter path [Array(String)] The lexical path where the value will be inserted.
		# @parameter value [Object] The value to insert at the specified path.
		def insert(path, value)
			node = @root
			
			# Navigate to the target node, creating nodes as needed:
			path.each do |key|
				node = (node.children[key] ||= Node.new)
			end
			
			# Add the value to the target node:
			(node.values ||= []) << value
		end
		
		# Lookup the values at the specified path.
		# @parameter path [Array(String)] The lexical path which contains the values.
		# @returns [Node | Nil] The node at the specified path, or nil if not found.
		def lookup(path)
			@root.lookup(path)
		end
		
		# Enumerate all lexical scopes under the specified path.
		# @parameter path [Array(String)] The starting path to enumerate from.
		# @yields {|path, values| ...} Called for each path with values.
		#   @parameter path [Array(String)] The lexical path.
		#   @parameter values [Array(Object) | Nil] The values that exist at the given path.
		def each(path = [], &block)
			if node = @root.lookup(path)
				node.traverse do |path, node, descend|
					yield path, node.values
					
					descend.call
				end
			end
		end
		
		# Traverse the trie starting from the specified path.
		# See {Node#traverse} for details.
		# @parameter path [Array(String)] The starting path to traverse from.
		# @yields {|path, node, descend| ...} Called for each node during traversal.
		def traverse(path = [], &block)
			if node = @root.lookup(path)
				node.traverse(&block)
			end
		end
	end
end
