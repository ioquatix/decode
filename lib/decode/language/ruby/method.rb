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

require_relative 'definition'

module Decode
	module Language
		module Ruby
			# A Ruby-specific method.
			class Method < Definition
				# The short form of the method.
				# e.g. `def puts`.
				def short_form
					@node.location.keyword.join(@node.location.name).source
				end
				
				# The node which contains the function arguments.
				def arguments_node
					if node = @node.children[1]
						if node.location.expression
							return node
						end
					end
				end
				
				# The long form of the method.
				# e.g. `def puts(*lines, separator: "\n")`.
				def long_form
					if arguments_node = self.arguments_node
						@node.location.keyword.join(
							arguments_node.location.expression
						).source
					else
						self.short_form
					end
				end
				
				# The fully qualified name of the block.
				# e.g. `::Barnyard#foo`.
				def qualified_form
					self.qualified_name
				end
				
				def convert(kind)
					case kind
					when :attribute
						Attribute.new(@node, @name,
							comments: @comments, parent: @parent, language: @language
						)
					else
						super
					end
				end
			end
		end
	end
end