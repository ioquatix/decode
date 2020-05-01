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

require 'parser/current'

require_relative 'class'
require_relative 'constant'
require_relative 'function'
require_relative 'method'
require_relative 'module'

module Decode
	module Language
		module Ruby
			class Parser
				def initialize(parser = ::Parser::CurrentRuby.new)
					@parser = parser
				end
				
				def parse(input, &block)
					buffer = ::Parser::Source::Buffer.new('(input)')
					buffer.source = input.read
					
					top, comments = @parser.parse_with_comments(buffer)
					
					walk(top, comments, &block)
				end
				
				def extract_comments_for(node, comments)
					prefix = []
					
					while comment = comments.first
						break if comment.location.line >= node.location.line
						
						if last_comment = prefix.last
							if last_comment.location.line != (comment.location.line - 1)
								prefix.clear
							end
						end
						
						prefix << comments.shift
					end
					
					# The last comment must butt up against the node:
					if comment = prefix.last
						if comment.location.line == (node.location.line - 1)
							return prefix.map do |comment|
								comment.text.sub(/\A\#\s?/, '')
							end
						end
					end
				end
				
				# Walk over the syntax tree and extract relevant definitions with their associated comments.
				def walk(node, comments, parent = nil, &block)
					case node.type
					when :begin
						node.children.each do |child|
							walk(child, comments, parent, &block)
						end
					when :module
						definition = Module.new(
							:module, node.children[0].children[1],
							extract_comments_for(node, comments), node,
							parent: parent, language: Ruby
						)
						
						yield definition
						
						if children = node.children[1]
							walk(children, comments, definition, &block)
						end
					when :class
						definition = Class.new(
							:class, node.children[0].children[1],
							extract_comments_for(node, comments), node,
							parent: parent, language: Ruby
						)
						
						yield definition
						
						if children = node.children[2]
							walk(children, comments, definition, &block)
						end
					when :sclass
						definition = Singleton.new(
							:class, node.children[0],
							extract_comments_for(node, comments), node,
							parent: parent, language: Ruby
						)
						
						yield definition
						
						if children = node.children[1]
							walk(children, comments, definition, &block)
						end
					when :def
						definition = Method.new(
							:def, node.children[0],
							extract_comments_for(node, comments), node,
							parent: parent, language: Ruby
						)
						
						yield definition
					when :defs
						definition = Function.new(
							:defs, node.children[1],
							extract_comments_for(node, comments), node,
							parent: parent, language: Ruby
						)
						
						yield definition
					when :casgn
						definition = Constant.new(
							:constant, node.children[1],
							extract_comments_for(node, comments), node,
							parent: parent, language: Ruby
						)
						
						yield definition
					end
				end
			end
		end
	end
end
