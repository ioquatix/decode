# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2025, by Samuel Williams.

require_relative "definition"

module Decode
	module Language
		module Ruby
			# A Ruby-specific class.
			class Class < Definition
				# Initialize a new class definition.
				# @parameter arguments [Array] The definition arguments.
				# @parameter super_class [String] The super class name.
				# @parameter options [Hash] Additional options.
				def initialize(*arguments, super_class: nil, **options)
					super(*arguments, **options)
					
					@super_class = super_class
					@generics = extract_generics_from_comments
				end
				
				attr :super_class
				attr :generics
				
				# A class is a container for other definitions.
				def container?
					true
				end
				
				# The short form of the class.
				# e.g. `class Animal`.
				def short_form
					"class #{self.name}"
				end
				
				# The long form of the class.
				# e.g. `class Dog < Animal`.
				def long_form
					if super_class = self.super_class
						"#{qualified_form} < #{super_class}"
					else
						qualified_form
					end
				end
				
				# The fully qualified name of the class.
				# e.g. `class ::Barnyard::Dog`.
				def qualified_form
					"class #{self.qualified_name}"
				end
				
				private
				
				# Extract generic type parameters from RBS pragmas in comments.
				# @returns [Array(String)] Array of generic type parameter names.
				def extract_generics_from_comments
					return [] unless @documentation
					
					generics = []
					
					@documentation.tags.each do |tag|
						if tag.is_a?(Comment::RBS) && tag.generic?
							# Extract generic parameters from "generic T" or "generic T, U"
							if parameter = tag.generic_parameter
								generics.concat(parameter.split(/\s*,\s*/))
							end
						end
					end
					
					generics
				end
			end
			
			# A Ruby-specific singleton class.
			class Singleton < Definition
				# Generate a nested name for the singleton class.
				def nested_name
					"class"
				end

				# A singleton class is a container for other definitions.
				# @returns [Boolean]
				def container?
					true
				end
				
				# Typically, a singleton class does not contain other definitions.
				# @returns [Boolean]
				def nested?
					false
				end
				
				# The short form of the class.
				# e.g. `class << self`.
				def short_form
					"class << #{self.name}"
				end
				
				# The long form is the same as the short form.
				alias long_form short_form
				
				private
				
				def absolute_path
					if @parent
						@parent.path
					else
						@name.to_s.split("::").map(&:to_sym)
					end
				end
			end
		end
	end
end
