# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "tag"

module Decode
	module Comment
		# Describes an attribute type.
		#
		# - `@attribute [Integer] The person's age.`
		#
		class Attribute < Tag
			PATTERN = /\A\[(?<type>.*?)\](\s+(?<details>.*?))?\Z/
			
			def self.build(directive, match)
				node = self.new(directive, match[:type])
				
				if details = match[:details]
					node.add(Text.new(details))
				end
				
				return node
			end
			
			def initialize(directive, type)
				super(directive)
				
				@type = type
			end
			
			# The type of the attribute.
			# @attribute [String]
			attr :type
		end
	end
end
