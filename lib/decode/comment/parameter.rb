# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "tag"

module Decode
	module Comment
		# Describes a named method parameter.
		#
		# - `@parameter age [Float] The users age.`
		#
		class Parameter < Tag
			PATTERN = /\A(?<name>.*?)\s+\[(?<type>.*?)\](\s+(?<details>.*?))?\Z/
			
			def self.build(directive, match)
				node = self.new(directive, match[:name], match[:type])
				
				if details = match[:details]
					node.add(Text.new(details))
				end
				
				return node
			end
			
			def initialize(directive, name, type)
				super(directive)
				
				@name = name
				@type = type
			end
			
			# The name of the parameter.
			# @attribute [String]
			attr :name
			
			# The type of the attribute.
			# @attribute [String]
			attr :type
		end
	end
end
