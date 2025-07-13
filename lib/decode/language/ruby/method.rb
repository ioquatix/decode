# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2025, by Samuel Williams.

require_relative "definition"

module Decode
	module Language
		module Ruby
			# A Ruby-specific method.
			class Method < Definition
				# Initialize a new method definition.
				# @parameter arguments [Array] The definition arguments.
				# @parameter receiver [String] The method receiver (for class methods).
				# @parameter options [Hash] Additional options.
				def initialize(*arguments, receiver: nil, **options)
					super(*arguments, **options)
					@receiver = receiver
				end
				
				attr :receiver
				
				# Generate a nested name for the method.
				def nested_name
					if @receiver
						".#{self.name}"
					else
						"##{self.name}"
					end
				end
				
				# The short form of the method.
				# e.g. `def puts` or `def self.puts`.
				def short_form
					if @receiver
						"def #{@receiver}.#{@node.name}"
					else
						"def #{@node.name}"
					end
				end
				
				# The node which contains the function arguments.
				def arguments_node
					@node.parameters
				end
				
				# The long form of the method.
				# e.g. `def puts(*lines, separator: "\n")` or `def self.puts(*lines, separator: "\n")`.
				def long_form
					if arguments_node = self.arguments_node
						if @receiver
							"def #{@receiver}.#{@node.name}(#{arguments_node.location.slice})"
						else
							"def #{@node.name}(#{arguments_node.location.slice})"
						end
					else
						self.short_form
					end
				end
				
				# The fully qualified name of the block.
				# e.g. `::Barnyard#foo`.
				def qualified_form
					self.qualified_name
				end
				
				# Override the qualified_name method to handle method name joining correctly
				def qualified_name
					@qualified_name ||= begin
						if @parent
							[@parent.qualified_name, self.nested_name].join("")
						else
							self.nested_name
						end
					end
				end
				
				# Convert the method to a different kind of definition.
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
