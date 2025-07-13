# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2025, by Samuel Williams.

require_relative "match"

module Decode
	# Provides syntax rewriting and linking functionality.
	module Syntax
		# Represents a link to a definition in the documentation.
		class Link < Match
			# Initialize a new link.
			# @parameter range [Range] The range of text to link.
			# @parameter definition [Definition] The definition to link to.
			def initialize(range, definition)
				@definition = definition
				
				super(range)
			end
			
			attr :definition
			
			# Apply the link to the output.
			# @parameter output [String] The output to append to.
			# @parameter rewriter [Rewriter] The rewriter instance.
			def apply(output, rewriter)
				output << rewriter.link_to(
					@definition,
					rewriter.text_for(@range)
				)
				
				return self.size
			end
		end
	end
end
