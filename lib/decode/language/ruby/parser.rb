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

require_relative '../../scope'

require_relative 'attribute'
require_relative 'block'
require_relative 'call'
require_relative 'class'
require_relative 'constant'
require_relative 'function'
require_relative 'method'
require_relative 'module'

require_relative 'segment'

module Decode
	module Language
		module Ruby
			# The Ruby source code parser.
			class Parser
				# Extract definitions from the given input file.
				def definitions_for(input, &block)
					top, comments = ::Parser::CurrentRuby.parse_with_comments(input.read)
					
					if top
						walk_definitions(top, comments, &block)
					end
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
				def walk_definitions(node, comments, parent = nil, &block)
					case node.type
					when :begin
						node.children.each do |child|
							walk_definitions(child, comments, parent, &block)
						end
					when :module
						definition = Module.new(
							node, node.children[0].children[1],
							comments: extract_comments_for(node, comments),
							parent: parent,
							language: Ruby
						)
						
						yield definition
						
						if children = node.children[1]
							walk_definitions(children, comments, definition, &block)
						end
					when :class
						definition = Class.new(
							node, node.children[0].children[1],
							comments: extract_comments_for(node, comments),
							parent: parent, language: Ruby
						)
						
						yield definition
						
						if children = node.children[2]
							walk_definitions(children, comments, definition, &block)
						end
					when :sclass
						definition = Singleton.new(
							node, node.children[0],
							comments: extract_comments_for(node, comments),
							parent: parent, language: Ruby
						)
						
						yield definition
						
						if children = node.children[1]
							walk_definitions(children, comments, definition, &block)
						end
					when :def
						definition = Method.new(
							node, node.children[0],
							comments: extract_comments_for(node, comments),
							parent: parent, language: Ruby
						)
						
						yield definition
					when :defs
						definition = Function.new(
							node, node.children[1],
							comments: extract_comments_for(node, comments),
							parent: parent, language: Ruby
						)
						
						yield definition
					when :casgn
						definition = Constant.new(
							node, node.children[1],
							comments: extract_comments_for(node, comments),
							parent: parent, language: Ruby
						)
						
						yield definition
					when :send
						name = node.children[1]
						case name
						when :attr, :attr_reader, :attr_writer, :attr_accessor
							definition = Attribute.new(
								node, name_for(node.children[2]),
								comments: extract_comments_for(node, comments),
								parent: parent, language: Ruby
							)
							
							yield definition
						else
							extracted_comments = extract_comments_for(node, comments)
							if kind = kind_for(node, extracted_comments)
								definition = Call.new(
									node, name_for(node, extracted_comments),
									comments: extracted_comments,
									parent: parent, language: Ruby
								)
								
								yield definition
							end
						end
					when :block
						extracted_comments = extract_comments_for(node, comments)
						
						if name = name_for(node, extracted_comments)
							definition = Block.new(
								node, name,
								comments: extracted_comments,
								parent: scope_for(extracted_comments, parent, &block),
								language: Ruby
							)
							
							if kind = kind_for(node, extracted_comments)
								definition = definition.convert(kind)
							end
							
							yield definition
							
							if children = node.children[2]
								walk_definitions(children, comments, definition, &block)
							end
						end
					end
				end
				
				NAME_ATTRIBUTE = /\A@name\s+(?<value>.*?)\Z/
				
				def name_for(node, comments = nil)
					comments&.each do |comment|
						if match = comment.match(NAME_ATTRIBUTE)
							return match[:value].to_sym
						end
					end
					
					case node.type
					when :sym
						return node.children[0]
					when :send
						return node.children[1]
					when :block
						return node.children[0].children[1]
					end
				end
				
				KIND_ATTRIBUTE = /\A
					(@(?<kind>attribute)\s+(?<value>.*?))|
					(@define\s+(?<kind>)\s+(?<value>.*?))
				\Z/x
				
				def kind_for(node, comments = nil)
					comments&.each do |comment|
						if match = comment.match(KIND_ATTRIBUTE)
							return match[:kind].to_sym
						end
					end
					
					return nil
				end
				
				SCOPE_ATTRIBUTE = /\A
					(@scope\s+(?<names>.*?))
				\Z/x
				
				def scope_for(comments, parent = nil, &block)
					comments&.each do |comment|
						if match = comment.match(SCOPE_ATTRIBUTE)
							return match[:names].split(/\s+/).map(&:to_sym).inject(nil) do |memo, name|
								scope = Scope.new(name, parent: memo, language: Ruby)
								yield scope
								scope
							end
						end
					end
					
					return parent
				end
				
				# Extract segments from the given input file.
				def segments_for(input, &block)
					top, comments = ::Parser::CurrentRuby.parse_with_comments(input.read)
					
					# We delete any leading comments:
					line = 0
					
					while comment = comments.first
						if comment.location.line == line
							comments.pop
							line += 1
						else
							break
						end
					end
					
					# Now we iterate over the syntax tree and generate segments:
					walk_segments(top, comments, &block)
				end
				
				def walk_segments(node, comments, &block)
					case node.type
					when :begin
						segment = nil
						
						node.children.each do |child|
							if segment.nil?
								segment = Segment.new(
									extract_comments_for(child, comments),
									Ruby,	child
								)
							elsif next_comments = extract_comments_for(child, comments)
								yield segment if segment
								segment = Segment.new(next_comments, Ruby, child)
							else
								segment.expand(child)
							end
						end
						
						yield segment if segment
					else
						# One top level segment:
						segment = Segment.new(
							extract_comments_for(node, comments),
							Ruby,	node
						)
						
						yield segment
					end
				end
			end
		end
	end
end
