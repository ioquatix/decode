# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "definition"

module Decode
	module Language
		module Ruby
			# A Ruby-specific block which might carry other definitions.
			class Call < Definition
				# A block can sometimes be a container for other definitions.
				def container?
					false
				end
				
				# The short form of the class.
				# e.g. `foo`.
				def short_form
					@name.to_s
				end
				
				# The long form of the class.
				# e.g. `foo(:bar)`.
				def long_form
					if @node.location.line == @node.location.last_line
						@node.location.expression.source
					else
						self.short_form
					end
				end
				
				# The fully qualified name of the block.
				# e.g. `class ::Barnyard::Dog`.
				def qualified_form
					self.qualified_name
				end
			end
		end
	end
end
