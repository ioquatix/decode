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

require_relative '../symbol'

require 'parser/current'

module Decode
	module Language
		class Ruby
			# The symbol which is used to separate the specified definition from the parent scope.
			PREFIX = {
				class: '::',
				module: '::',
				def: ':',
				constant: '::',
				defs: '.',
			}.freeze
			
			KIND =  {
				':' => :def,
				'.' => :defs,
			}.freeze
			
			class Reference
				def initialize(value)
					@value = value
					
					@path = nil
					@kind = nil
				end
				
				def absolute?
					@value.start_with?('::')
				end
				
				METHOD = /\A(?<scope>.*?)?(?<kind>:|\.)(?<name>.+?)\z/
				
				def path
					if @path.nil?
						@path = @value.split(/::/)
						
						if last = @path.pop
							if match = last.match(METHOD)
								@kind = KIND[match[:kind]]
								
								if scope = match[:scope]
									@path << scope
								end
								
								@path << match[:name]
							else
								@path << last
							end
						end
						
						@path = @path.map(&:to_sym)
						@path.freeze
					end
					
					return @path
				end
				
				def kind
					self.path
					
					return @kind
				end
			end
			
			def join(symbols, absolute = true)
				buffer = String.new
				
				symbols.each do |symbol|
					if absolute == false
						absolute = true
					else
						buffer << PREFIX[symbol.kind]
					end
					
					buffer << symbol.name.to_s
				end
				
				return buffer
			end
			
			def parse(input, &block)
				parser = ::Parser::CurrentRuby.new
				
				buffer = ::Parser::Source::Buffer.new('(input)')
				buffer.source = input.read
				
				top, comments = parser.parse_with_comments(buffer)
				
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
				when :class
					definition = Definition.new(
						:class, node.children[0].children[1],
						node, extract_comments_for(node, comments),
						parent: parent, language: self
					)
					
					yield definition
					
					walk(node.children[2], comments, definition, &block)
				when :module
					definition = Definition.new(
						:module, node.children[0].children[1],
						node, extract_comments_for(node, comments),
						parent: parent, language: self
					)
					
					yield definition
					
					walk(node.children[1], comments, definition, &block)
				when :def
					definition = Definition.new(
						:def, node.children[0],
						node, extract_comments_for(node, comments),
						parent: parent, language: self
					)
					
					yield definition
					
					# if body = node.children[2]
					# 	walk(body, comments, definition, &block)
					# end
				when :defs
					definition = Definition.new(
						:defs, node.children[1],
						node, extract_comments_for(node, comments),
						parent: parent, language: self
					)
					
					yield definition
					
					# if body = node.children[2]
					# 	walk(body, comments, definition, &block)
					# end
				when :casgn
					definition = Definition.new(
						:constant, node.children[1],
						node, extract_comments_for(node, comments),
						parent: parent, language: self
					)
					
					yield definition
				end
			end
		end
	end
end
