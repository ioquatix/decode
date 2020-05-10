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

module Decode
	module Comment
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
			
			# Any children of this node.
			# @attribute [Array(Node | Text) | Nil]
			attr :children
			
			# Enumerate all non-text children nodes.
			def each(&block)
				return to_enum unless block_given?
				
				@children&.each do |child|
					yield child if child.is_a?(Node)
				end
			end
			
			# Any lines of text associated wtih this node.
			# @returns [Array(String) | Nil] The lines of text.
			def text
				if text = self.extract_text
					return text if text.any?
				end
			end
			
			# Traverse the tags from this node using {each}.
			# Invoke `descend.call(child)` to recursively traverse the specified child.
			#
			# @yields {|node, descend| descend.call}
			# 	@parameter node [Node] The current node which is being traversed.
			# 	@parameter descend [Proc | Nil] The recursive method for traversing children.
			def traverse(&block)
				descend = ->(node){
					node.traverse(&block)
				}
				
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
