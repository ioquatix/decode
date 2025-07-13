# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2025, by Samuel Williams.

require_relative "definition"

module Decode
	module Language
		module Ruby
			# A Ruby-specific block which might carry other definitions.
			class Block < Definition
				# A block can sometimes be a container for other definitions.
				def container?
					true
				end
				
				# Generate a nested name for the block.
				def nested_name
					".#{name}"
				end
				
				# The short form of the block.
				# e.g. `foo`.
				def short_form
					@name.to_s
				end
				
				# The long form of the block.
				# e.g. `foo(:bar)`.
				def long_form
					if @node.location.line == @node.location.last_line
						@node.location.expression.source
					else
						@node.children[0].location.expression.source
					end
				end
				
				# The fully qualified name of the block.
				# e.g. `::Barnyard::foo`.
				def qualified_form
					self.qualified_name
				end
				
				# Convert the block to a different kind of definition.
				# @parameter kind [Symbol] The kind to convert to.
				def convert(kind)
					case kind
					when :attribute
						Attribute.new(@node, @name,
							comments: @comments, parent: @parent, language: @language
						)
					else
						super
					end
				end
			end
		end
	end
end
