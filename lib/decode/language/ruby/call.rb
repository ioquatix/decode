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
					@node&.block && @node.block.opening == "do"
				end
				
				# The short form of the class.
				# e.g. `foo`.
				def short_form
					if @node&.block && @node.block.opening == "{"
						"#{name} { ... }"
					else
						name.to_s
					end
				end
				
				# The long form of the class.
				# e.g. `foo(:bar)`.
				def long_form
					if @node.location.start_line == @node.location.end_line
						@node.location.slice
					else
						# For multiline calls, use the actual call name with arguments
						if @node.arguments && @node.arguments.arguments.any?
							arg_text = @node.arguments.arguments.map { |arg| arg.location.slice }.join(", ")
							"#{@node.name}(#{arg_text})"
						else
							@node.name.to_s
						end
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
