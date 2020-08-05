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

require_relative '../../definition'

module Decode
	module Language
		module Ruby
			# A Ruby-specific definition.
			class Definition < Decode::Definition
				# Initialize the definition from the syntax tree node.
				def initialize(node, *arguments, **options)
					super(*arguments, **options)
					
					@node = node
				end
				
				def nested_name
					"\##{@name}"
				end
				
				# The parser syntax tree node.
				attr :node
				
				def multiline?
					@node.location.line != @node.location.last_line
				end
				
				# The source code associated with the definition.
				# @returns [String]
				def text
					expression = @node.location.expression
					lines = expression.source.lines
					if lines.count == 1
						return lines.first
					else
						if indentation = expression.source_line[/\A\s+/]
							# Remove all the indentation:
							lines.each{|line| line.sub!(indentation, '')}
						end
						
						return lines.join
					end
				end
			end
		end
	end
end