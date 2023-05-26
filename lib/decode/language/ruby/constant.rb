# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020, by Samuel Williams.

require_relative 'definition'

module Decode
	module Language
		module Ruby
			# A Ruby-specific constant.
			class Constant < Definition
				# The short form of the constant.
				# e.g. `NAME`.
				def short_form
					@node.location.name.source
				end
				
				def nested_name
					"::#{@name}"
				end
				
				# The long form of the constant.
				# e.g. `NAME = "Alice"`.
				def long_form
					if @node.location.line == @node.location.last_line
						@node.location.expression.source
					elsif @node.children[2].type == :array
						"#{@name} = [...]"
					elsif @node.children[2].type == :hash
						"#{@name} = {...}"
					else
						self.short_form
					end
				end
			end
		end
	end
end
