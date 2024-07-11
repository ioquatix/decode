# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

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
				def initialize(language)
					@language = language
					@visibility = :public
					
					@definitions = Hash.new.compare_by_identity
				end
				
				private def assign_definition(parent, definition)
					(@definitions[parent] ||= {})[definition.name] = definition
				end
				
				private def lookup_definition(parent, name)
					(@definitions[parent] ||= {})[name]
				end
				
				# Parse the given source object, can be a string or a Source instance.
				# @parameter source [String | Source] The source to parse.
				private def parse_source(source)
					if source.is_a?(Source)
						::Parser::CurrentRuby.parse_with_comments(source.read, source.relative_path)
					else
						::Parser::CurrentRuby.parse_with_comments(source)
					end
				end
				
				# Extract definitions from the given input file.
				def definitions_for(source, &block)
					top, comments = self.parse_source(source)
					
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
				
				def with_visibility(visibility = :public, &block)
					saved_visibility = @visibility
					@visibility = visibility
					yield
				ensure
					@visibility = saved_visibility
				end
				
				# Walk over the syntax tree and extract relevant definitions with their associated comments.
				def walk_definitions(node, comments, parent = nil, &block)
					case node.type
					when :module
						definition = Module.new(
							node, nested_name_for(node.children[0]),
							comments: extract_comments_for(node, comments),
							parent: parent,
							language: @language
						)
						
						assign_definition(parent, definition)
						
						yield definition
						
						if children = node.children[1]
							with_visibility do
								walk_definitions(children, comments, definition, &block)
							end
						end
					when :class
						definition = Class.new(
							node, nested_name_for(node.children[0]),
							comments: extract_comments_for(node, comments),
							parent: parent, language: @language
						)
						
						assign_definition(parent, definition)
						
						yield definition
						
						if children = node.children[2]
							with_visibility do
								walk_definitions(children, comments, definition, &block)
							end
						end
					when :sclass
						if name = singleton_name_for(node.children[0])
							definition = Singleton.new(
								node, name,
								comments: extract_comments_for(node, comments),
								parent: parent, language: @language
							)
							
							yield definition
							
							if children = node.children[1]
								walk_definitions(children, comments, definition, &block)
							end
						end
					when :def
						definition = Method.new(
							node, node.children[0],
							comments: extract_comments_for(node, comments),
							parent: parent, language: @language, visibility: @visibility
						)
						
						yield definition
					when :defs
						extracted_comments = extract_comments_for(node, comments)
						
						definition = Function.new(
							node, node.children[1],
							comments: extracted_comments,
							parent: scope_for(extracted_comments, parent, &block),
							language: @language
						)
						
						yield definition
					when :casgn
						definition = Constant.new(
							node, node.children[1],
							comments: extract_comments_for(node, comments),
							parent: parent, language: @language
						)
						
						yield definition
					when :send
						name = node.children[1]
						
						case name
						when :public, :protected, :private
							@visibility = name
						when :private_constant
							constant_names_for(node.children[2..]) do |name|
								if definition = lookup_definition(parent, name)
									definition.visibility = :private
								end
							end
						when :attr, :attr_reader, :attr_writer, :attr_accessor
							definition = Attribute.new(
								node, name_for(node.children[2]),
								comments: extract_comments_for(node, comments),
								parent: parent, language: @language
							)
							
							yield definition
						else
							extracted_comments = extract_comments_for(node, comments)
							if kind = kind_for(node, extracted_comments)
								definition = Call.new(
									node, name_for(node, extracted_comments),
									comments: extracted_comments,
									parent: parent, language: @language
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
								language: @language
							)
							
							if kind = kind_for(node, extracted_comments)
								definition = definition.convert(kind)
							end
							
							yield definition
							
							if children = node.children[2]
								walk_definitions(children, comments, definition, &block)
							end
						end
					else
						node.children.each do |child|
							if child.is_a?(::Parser::AST::Node)
								walk_definitions(child, comments, parent, &block) if child
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
				
				def nested_name_for(node)
					if prefix = node.children[0]
						"#{nested_name_for(prefix)}::#{node.children[1]}".to_sym
					else
						node.children[1]
					end
				end
				
				def singleton_name_for(node)
					case node.type
					when :const
						nested_name_for(node)
					when :self
						:'self'
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
								scope = Scope.new(name, parent: memo, language: @language)
								yield scope
								scope
							end
						end
					end
					
					return parent
				end
				
				def constant_names_for(children)
					children.each do |node|
						if node.type == :sym
							yield node.children[0]
						end
					end
				end
				
				# Extract segments from the given input file.
				def segments_for(source, &block)
					top, comments = self.parse_source(source)
					
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
									@language,	child
								)
							elsif next_comments = extract_comments_for(child, comments)
								yield segment if segment
								segment = Segment.new(next_comments, @language, child)
							else
								segment.expand(child)
							end
						end
						
						yield segment if segment
					else
						# One top level segment:
						segment = Segment.new(
							extract_comments_for(node, comments),
							@language, node
						)
						
						yield segment
					end
				end
			end
		end
	end
end
