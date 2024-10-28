# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "match"

module Decode
	module Syntax
		class Link < Match
			def initialize(range, definition)
				@definition = definition
				
				super(range)
			end
			
			attr :definition
			
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
