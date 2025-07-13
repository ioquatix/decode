# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2025, by Samuel Williams.

require_relative "definition"

module Decode
	module Language
		module Ruby
			# A Ruby-specific constant.
			class Constant < Definition
				# The short form of the constant.
				# e.g. `NAME`.
				def short_form
					@node.name.to_s
				end
				
				# Generate a nested name for the constant.
				def nested_name
					"::#{@name}"
				end
				
				# The long form of the constant.
				# e.g. `NAME = "Alice"`.
				def long_form
					if @node.location.start_line == @node.location.end_line
						@node.location.slice
					elsif @node.value&.type == :array_node
						"#{@node.name} = [...]"
					elsif @node.value&.type == :hash_node
						"#{@node.name} = {...}"
					else
						self.short_form
					end
				end
			end
		end
	end
end
