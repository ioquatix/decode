# Copyright, 2020, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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
		
		def to_s
			"\#<#{self.class} #{qualified_name}>"
		end
		
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
				@path = [*@parent.path, @name].freeze
			else
				# At top:
				@path = [@name].freeze
			end
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
	end
end
