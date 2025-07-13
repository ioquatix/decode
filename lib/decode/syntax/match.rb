# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2025, by Samuel Williams.

module Decode
	module Syntax
		# Represents a match in the source text for syntax rewriting.
		class Match
			# Initialize a new match.
			# @parameter range [Range] The range of text this match covers.
			def initialize(range)
				@range = range
			end
			
			attr :range
			
			# Apply the match to extract text from source.
			# @parameter source [String] The source text.
			def apply(source)
				return source[range]
			end
			
			# Compare matches by their starting position.
			# @parameter other [Match] The other match to compare.
			def <=> other
				@range.min <=> other.range.min
			end
			
			# Get the starting offset of this match.
			def offset
				@range.min
			end
			
			# Get the size of this match.
			def size
				@range.size
			end
			
			# Apply the match to the output.
			# @parameter output [String] The output to append to.
			# @parameter rewriter [Rewriter] The rewriter instance.
			def apply(output, rewriter)
				output << rewriter.text_for(@range)
				
				return self.size
			end
		end
	end
end
