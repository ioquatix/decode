# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020, by Samuel Williams.

require_relative 'documentation'

module Decode
	# A chunk of code with an optional preceeding comment block.
	#
	#	~~~ ruby
	#	# Get the first segment from a source file:
	#	segment = source.segments.first
	#	~~~
	#
	class Segment
		def initialize(comments, language)
			@comments = comments
			@language = language
		end
		
		# The preceeding comments.
		# @attribute [Array(String)]
		attr :comments
		
		# The language of the code attached to this segment.
		# @attribute [Language::Generic]
		attr :language
		
		# An interface for accsssing the documentation of the definition.
		# @returns [Documentation | nil] A {Documentation} instance if this definition has comments.
		def documentation
			if @comments&.any?
				@documentation ||= Documentation.new(@comments, @language)
			end
		end
		
		# The source code trailing the comments.
		# @returns [String | nil]
		def code
		end
	end
end
