# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020, by Samuel Williams.

require_relative 'definition'

module Decode
	module Language
		module Ruby
			# A Ruby-specific method.
			class Method < Definition
				# The short form of the method.
				# e.g. `def puts`.
				def short_form
					@node.location.keyword.join(@node.location.name).source
				end
				
				# The node which contains the function arguments.
				def arguments_node
					if node = @node.children[1]
						if node.location.expression
							return node
						end
					end
				end
				
				# The long form of the method.
				# e.g. `def puts(*lines, separator: "\n")`.
				def long_form
					if arguments_node = self.arguments_node
						@node.location.keyword.join(
							arguments_node.location.expression
						).source
					else
						self.short_form
					end
				end
				
				# The fully qualified name of the block.
				# e.g. `::Barnyard#foo`.
				def qualified_form
					self.qualified_name
				end
				
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
