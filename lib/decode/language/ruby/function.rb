# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2025, by Samuel Williams.

require_relative "method"

module Decode
	module Language
		module Ruby
			# A Ruby-specific function.
			class Function < Method
				# Generate a nested name for the function.
				def nested_name
					".#{@name}"
				end
				
				# The node which contains the function arguments.
				def arguments_node
					if node = @node.children[2]
						if node.location.expression
							return node
						end
					end
				end
			end
		end
	end
end
