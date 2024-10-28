# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "location"

module Decode
	# A symbol with attached documentation.
	class Definition
		# Initialize the symbol.
		# @parameter name [Symbol] The name of the definition.
		# @parameter parent [Symbol] The parent lexical scope.
		# @parameter language [Language] The language in which the symbol is defined in.
		# @parameter comments [Array(String)] The comments associated with the definition.
		def initialize(name, parent: nil, language: parent.language, comments: nil)
			@name = name
			
			@parent = parent
			@language = language
			
			@comments = comments
			
			@path = nil
			@qualified_name = nil
		end
		
		def inspect
			"\#<#{self.class} #{qualified_name}>"
		end
		
		alias to_s inspect

		# The symbol name.
		# e.g. `:Decode`.
		# @attribute [Symbol]
		attr :name
		
		# The parent definition, defining lexical scope.
		# @attribute [Definition | Nil]
		attr :parent
		
		# The language the symbol is defined within.
		# @attribute [Language::Generic]
		attr :language
		
		# The comment lines which directly preceeded the definition.
		# @attribute [Array(String)]
		attr :comments
		
		# Whether the definition is considered part of the public interface.
		#
		# This is used to determine whether the definition should be documented for coverage purposes.
		#
		# @returns [Boolean]
		def public?
			true
		end
		
		# The qualified name is an absolute name which includes any and all namespacing.
		# @returns [String]
		def qualified_name
			@qualified_name ||= begin
				if @parent
					@parent.qualified_name + self.nested_name
				else
					@name.to_s
				end
			end
		end
		
		# The name of this definition plus the nesting prefix.
		# @returns [String]
		def nested_name
			"::#{@name}"
		end
		
		# Does the definition name match the specified prefix?
		# @returns [Boolean]
		def start_with?(prefix)
			self.nested_name.start_with?(prefix)
		end
		
		# Convert this definition into another kind of definition.
		def convert(kind)
			raise ArgumentError, "Unable to convert #{self} into #{kind}!"
		end
		
		# The lexical scope as an array of names.
		# e.g. `[:Decode, :Definition]`
		# @returns [Array]
		def path
			if @path
				# Cached version:
				@path
			elsif @parent
				# Merge with parent:
				@path = [*@parent.path, *path_name].freeze
			else
				# At top:
				@path = path_name.freeze
			end
		end
		
		def path_name
			[@name]
		end
		
		alias lexical_path path
		
		# A short form of the definition.
		# e.g. `def short_form`.
		#
		# @returns [String | nil]
		def short_form
		end
		
		# A long form of the definition.
		# e.g. `def initialize(kind, name, comments, **options)`.
		#
		# @returns [String | nil]
		def long_form
			self.short_form
		end
		
		# A long form which uses the qualified name if possible.
		# Defaults to {long_form}.
		#
		# @returns [String | nil]
		def qualified_form
			self.long_form
		end
		
		# Whether the definition spans multiple lines.
		#
		# @returns [Boolean]
		def multiline?
			false
		end
		
		# The full text of the definition.
		#
		# @returns [String | nil]
		def text
		end
		
		# Whether this definition can contain nested definitions.
		#
		# @returns [Boolean]
		def container?
			false
		end
		
		# Whether this represents a single entity to be documented (along with it's contents).
		#
		# @returns [Boolean]
		def nested?
			container?
		end
		
		# Structured access to the definitions comments.
		#
		# @returns [Documentation | Nil] A {Documentation} instance if this definition has comments.
		def documentation
			if @comments&.any?
				@documentation ||= Documentation.new(@comments, @language)
			end
		end
		
		# The location of the definition.
		#
		# @returns [Location | Nil] A {Location} instance if this definition has a location.
		def location
			nil
		end
	end
end
