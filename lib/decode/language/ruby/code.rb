# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "definition"
require_relative "../../syntax/link"

require "prism"

module Decode
	module Language
		module Ruby
			# A Ruby-specific block of code.
			class Code
				# Initialize a new code block.
				# @parameter text [String] The code text.
				# @parameter index [Index] The index to use.
				# @parameter relative_to [Definition] The definition this code is relative to.
				# @parameter language [Language] The language of the code.
				def initialize(text, index, relative_to: nil, language: relative_to&.language)
					@text = text
					@root = ::Prism.parse(text)
					@index = index
					@relative_to = relative_to
					@language = language
				end
				
				attr :text
				
				attr :language
				
				# Extract definitions from the code.
				# @parameter into [Array] The array to extract definitions into.
				def extract(into = [])
					if @index
						traverse(@root.value, into)
					end
					
					return into
				end
				
				private
				
				def traverse(node, into)
					case node&.type
					when :program_node
						traverse(node.statements, into)
					when :call_node
						if reference = Reference.from_const(node, @language)
							if definition = @index.lookup(reference, relative_to: @relative_to)
								# Use message_loc for the method name, not the entire call
								expression = node.message_loc
								range = expression.start_offset...expression.end_offset
								into << Syntax::Link.new(range, definition)
							end
						end
						
						# Extract constants from arguments:
						if node.arguments
							node.arguments.arguments.each do |arg_node|
								traverse(arg_node, into)
							end
						end
					when :constant_read_node
						if reference = Reference.from_const(node, @language)
							if definition = @index.lookup(reference, relative_to: @relative_to)
								expression = node.location
								range = expression.start_offset...expression.end_offset
								into << Syntax::Link.new(range, definition)
							end
						end
					when :statements_node
						node.body.each do |child|
							traverse(child, into)
						end
					end
				end
			end
		end
	end
end
