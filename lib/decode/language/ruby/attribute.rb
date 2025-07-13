# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2025, by Samuel Williams.

require_relative "definition"

module Decode
	module Language
		module Ruby
			# A Ruby-specific attribute.
			class Attribute < Definition
				# The short form of the attribute.
				# e.g. `attr :value`.
				def short_form
					case @node&.type
					when :block_node
						"#{@name} { ... }"
					else
						@node&.location&.slice || @name
					end
				end
				
				# Generate a long form representation of the attribute.
				def long_form
					if @node&.location&.start_line == @node&.location&.end_line
						@node.location.slice
					else
						short_form
					end
				end
			end
		end
	end
end
