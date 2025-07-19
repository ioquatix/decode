# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2025, by Samuel Williams.

require_relative "node"

module Decode
	module Comment
		# Represents a documentation tag parsed from a comment directive.
		class Tag < Node
			# Build a pattern for bracketed content, supporting nested brackets.
			# @parameter name [String] The name of the group.
			# @returns [String] The pattern.
			def self.bracketed_content(name)
				"(?<#{name}>(?:[^\\[\\]]+|\\[\\g<#{name}>\\])*)"
			end
			
			# Match text against the tag pattern.
			# @parameter text [String] The text to match.
			def self.match(text)
				self::PATTERN.match(text)
			end
			
			# Parse a tag from a directive and text.
			# @parameter directive [String] The directive name.
			# @parameter text [String] The directive text.
			# @parameter lines [Array(String)] The remaining lines.
			# @parameter tags [Tags] The tags parser.
			# @parameter level [Integer] The indentation level.
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
			
			# Initialize a new tag.
			# @parameter directive [String] The directive that generated the tag.
			def initialize(directive)
				@directive = directive
			end
			
			# @attribute [String] The directive that generated the tag.
			attr :directive
		end
	end
end
