# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2025, by Samuel Williams.

require_relative "text"

module Decode
	module Comment
		# Represents a collection of documentation tags and their parsing logic.
		class Tags
			# Build a tags parser with directive mappings.
			# @parameter block [Proc] A block that yields the directives hash.
			def self.build
				directives = Hash.new
				
				yield directives
				
				return self.new(directives)
			end
			
			# Initialize a new tags parser.
			# @parameter directives [Hash(String, Class)] The directive mappings.
			def initialize(directives)
				@directives = directives
			end
			
			# Check if a line has valid indentation for the given level.
			# @parameter line [String] The line to check.
			# @parameter level [Integer] The expected indentation level.
			def valid_indentation?(line, level)
				line.start_with?("  " * level) || line.start_with?("\t" * level)
			end
			
			PATTERN = /\A\s*@(?<directive>.*?)(\s+(?<remainder>.*?))?\Z/
			
			# Parse documentation tags from lines.
			# @parameter lines [Array(String)] The lines to parse.
			# @parameter level [Integer] The indentation level.
			# @parameter block [Proc] A block to yield parsed tags to.
			def parse(lines, level = 0, &block)
				while line = lines.first
					# Is it at the right indentation level:
					return unless valid_indentation?(line, level)
					
					# We are going to consume the line:
					lines.shift
					
					# Match it against a tag:
					if match = PATTERN.match(line)
						if klass = @directives[match[:directive]]
							yield klass.parse(
								match[:directive], match[:remainder],
								lines, self, level
							)
						else
							# Ignore unknown directive.
						end
						
					# Or it's just text:
					else
						yield Text.new(line)
					end
				end
			end
			
			# Ignore lines at the specified indentation level.
			# @parameter lines [Array(String)] The lines to ignore.
			# @parameter level [Integer] The indentation level.
			def ignore(lines, level = 0)
				if line = lines.first
					# Is it at the right indentation level:
					return unless valid_indentation?(line, level)
					
					lines.shift
				end
			end
		end
	end
end
