# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020, by Samuel Williams.

module Decode
	module Syntax
		class Match
			def initialize(range)
				@range = range
			end
			
			attr :range
			
			def apply(source)
				return source[range]
			end
			
			def <=> other
				@range.min <=> other.range.min
			end
			
			def offset
				@range.min
			end
			
			def size
				@range.size
			end
			
			def apply(output, rewriter)
				output << rewriter.text_for(@range)
				
				return self.size
			end
		end
	end
end
