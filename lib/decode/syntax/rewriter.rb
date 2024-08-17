# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

module Decode
	module Syntax
		class Rewriter
			def initialize(text)
				@text = text
				@matches = []
			end
			
			attr :text
			
			attr :matches
			
			def << match
				@matches << match
			end
			
			# Returns a chunk of raw text with no formatting.
			def text_for(range)
				@text[range]
			end
			
			def apply(output = [])
				offset = 0
				
				@matches.sort.each do |match|
					if match.offset > offset
						output << text_for(offset...match.offset)
						
						offset = match.offset
					elsif match.offset < offset
						# Match intersects last output buffer.
						next
					end
					
					offset += match.apply(output, self)
				end
				
				if offset < @text.size
					output << text_for(offset...@text.size)
				end
				
				return output
			end
			
			def link_to(definition, text)
				"[#{text}]"
			end
		end
	end
end
