# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "node"

module Decode
	module Comment
		class Tag < Node
			def self.match(text)
				self::PATTERN.match(text)
			end
			
			def self.parse(directive, text, lines, tags, level = 0)
				if match = self.match(text)
					node = self.build(directive, match)
					
					tags.parse(lines, level + 1) do |child|
						node.add(child)
					end
					
					return node
				else
					# Consume all nested nodes:
					tags.ignore(lines, level + 1)
				end
			end
			
			def initialize(directive)
				@directive = directive
			end
			
			# The directive that generated the tag.
			# @attribute [String]
			attr :directive
		end
	end
end
