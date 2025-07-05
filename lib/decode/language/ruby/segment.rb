# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "../../segment"

module Decode
	module Language
		module Ruby
			# A Ruby specific code segment.
			class Segment < Decode::Segment
				def initialize(comments, language, node, **options)
					super(comments, language, **options)
					
					@node = node
					@expression = node.location
				end
				
				# The parser syntax tree node.
				attr :node
				
				def expand(node)
					@expression = @expression.join(node.location)
				end
				
				# The source code trailing the comments.
				# @returns [String | nil]
				def code
					@expression.slice
				end
			end
		end
	end
end
