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
require_relative '../../syntax/link'

require 'parser/current'

module Decode
	module Language
		module Ruby
			# A Ruby-specific block of code.
			class Code
				def initialize(text, index, relative_to: nil, language: relative_to&.language)
					@text = text
					@root = ::Parser::CurrentRuby.parse(text)
					@index = index
					@relative_to = relative_to
					@language = language
				end
				
				attr :text
				
				attr :language
				
				def extract(into = [])
					if @index
						traverse(@root, into)
					end
					
					return into
				end
				
				private
				
				def traverse(node, into)
					case node&.type
					when :send
						if reference = Reference.from_const(node, @language)
							if definition = @index.lookup(reference, relative_to: @relative_to)
								expression = node.location.selector
								range = expression.begin_pos...expression.end_pos
								into << Syntax::Link.new(range, definition)
							end
						end
						
						# Extract constants from arguments:
						children = node.children[2..-1].each do |node|
							traverse(node, into)
						end
					when :const
						if reference = Reference.from_const(node, @language)
							if definition = @index.lookup(reference, relative_to: @relative_to)
								expression = node.location.name
								range = expression.begin_pos...expression.end_pos
								into << Syntax::Link.new(range, definition)
							end
						end
					when :begin
						node.children.each do |child|
							traverse(child, into)
						end
					end
				end
			end
		end
	end
end