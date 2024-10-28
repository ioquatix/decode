# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "definition"

module Decode
	module Language
		module Ruby
			# A Ruby-specific attribute.
			class Attribute < Definition
				# The short form of the attribute.
				# e.g. `attr :value`.
				def short_form
					case @node.type
					when :block
						"#{@name} { ... }"
					else
						@node.location.expression.source
					end
				end
				
				def long_form
					if @node.location.line == @node.location.last_line
						@node.location.expression.source
					else
						short_form
					end
				end
			end
		end
	end
end
