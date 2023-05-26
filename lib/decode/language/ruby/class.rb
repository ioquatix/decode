# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

require_relative 'definition'

module Decode
	module Language
		module Ruby
			# A Ruby-specific class.
			class Class < Definition
				# A class is a container for other definitions.
				def container?
					true
				end
				
				def nested_name
					"::#{name}"
				end
				
				# The short form of the class.
				# e.g. `class Animal`.
				def short_form
					"class #{path_name.last}"
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
				
				def super_class
					if super_node = @node.children[1]
						super_node.location.expression.source
					end
				end
				
				# The fully qualified name of the class.
				# e.g. `class ::Barnyard::Dog`.
				def qualified_form
					"class #{self.qualified_name}"
				end
				
				def path_name
					@name.to_s.split('::').map(&:to_sym)
				end
			end
			
			# A Ruby-specific singleton class.
			class Singleton < Definition
				def nested_name
					"::class"
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
					"class << #{@name}"
				end
				
				# The long form is the same as the short form.
				alias long_form short_form

				def path_name
					[:class]
				end

				# The lexical scope as an array of names.
				# e.g. `[:Decode, :Definition]`
				# @returns [Array]
				def path
					if @path
						# Cached version:
						@path
					else
						@path = [*self.absolute_path, *self.path_name]
					end
				end

				private

				def absolute_path
					if @parent
						@parent.path
					else
						@name.to_s.split('::').map(&:to_sym)
					end
				end
			end
		end
	end
end
