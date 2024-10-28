# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "tag"

module Decode
	module Comment
		# Describes a block parameter.
		#
		# - `@yields {|person| ... } If a block is given.`
		#
		# Should contain nested parameters.
		class Yields < Tag
			PATTERN = /\A(?<block>{.*?})(\s+(?<details>.*?))?\Z/
			
			def self.build(directive, match)
				node = self.new(directive, match[:block])
				
				if details = match[:details]
					node.add(Text.new(details))
				end
				
				return node
			end
			
			def initialize(directive, block)
				super(directive)
				
				@block = block
			end
			
			attr :block
		end
	end
end
