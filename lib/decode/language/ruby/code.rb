# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

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
