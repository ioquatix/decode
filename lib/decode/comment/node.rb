# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2025, by Samuel Williams.

module Decode
	module Comment
		# Represents a node in a comment tree structure.
		class Node
			# Initialize the node.
			# @parameter children [Array(Node) | Nil]
			def initialize(children = nil)
				@children = children
			end
			
			# Whether this node has any children nodes.
			# Ignores {Text} instances.
			# @returns [Boolean]
			def children?
				@children&.any?{|child| child.is_a?(Node)}
			end
			
			# Add a child node to this node.
			# @parameter child [Node] The node to add.
			def add(child)
				@children ||= []
				@children << child
			end
			
			# @attribute [Array(Node | Text) | Nil] Any children of this node.
			attr :children
			
			# Enumerate all non-text children nodes.
			def each(&block)
				return to_enum unless block_given?
				
				@children&.each do |child|
					yield child if child.is_a?(Node)
				end
			end
			
			# Filter children nodes by class type.
			# @parameter klass [Class] The class to filter by.
			def filter(klass)
				return to_enum(:filter, klass) unless block_given?
				
				@children&.each do |child|
					yield child if child.is_a?(klass)
				end
			end
			
			# Any lines of text associated with this node.
			# @returns [Array(String) | Nil] The lines of text.
			def text
				if text = self.extract_text
					return text if text.any?
				end
			end
			
			# Traverse the tags from this node using {each}. Invoke `descend.call(child)` to recursively traverse the specified child.
			#
			# @yields {|node, descend| descend.call}
			# 	@parameter node [Node] The current node which is being traversed.
			# 	@parameter descend [Proc | Nil] The recursive method for traversing children.
			def traverse(&block)
				descend = ->(node){node.traverse(&block)}
				
				yield(self, descend)
			end
			
			protected
			
			def extract_text
				if children = @children
					@children.select{|child| child.kind_of?(Text)}.map(&:line)
				else
					nil
				end
			end
		end
	end
end
