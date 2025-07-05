# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "../../definition"

module Decode
	module Language
		module Ruby
			# A Ruby-specific definition.
			class Definition < Decode::Definition
				# Initialize the definition from the syntax tree node.
				def initialize(*arguments, visibility: nil, node: nil, **options)
					super(*arguments, **options)
					
					@visibility = visibility
					@node = node
				end
				
				# @attribute [Parser::AST::Node] The parser syntax tree node.
				attr :node
				
				# @attribute [Symbol] The visibility of the definition.
				attr_accessor :visibility
				
				def public?
					@visibility == :public
				end
				
				def multiline?
					@node.location.start_line != @node.location.end_line
				end
				
				# The source code associated with the definition.
				# @returns [String]
				def text
					expression = @node.location
					lines = expression.slice.lines
					if lines.count == 1
						return lines.first
					else
						if indentation = expression.slice.lines.first[/\A\s+/]
							# Remove all the indentation:
							lines.each{|line| line.sub!(indentation, "")}
						end
						
						return lines.join
					end
				end
				
				def location
					if @source
						Location.new(@source.path, @node.location.start_line)
					end
				end
			end
		end
	end
end
