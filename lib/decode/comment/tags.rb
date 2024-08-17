# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative 'text'

module Decode
	module Comment
		class Tags
			def self.build
				directives = Hash.new
				
				yield directives
				
				return self.new(directives)
			end
			
			def initialize(directives)
				@directives = directives
			end
			
			def valid_indentation?(line, level)
				line.start_with?('  ' * level) || line.start_with?("\t" * level)
			end
			
			PATTERN = /\A\s*@(?<directive>.*?)(\s+(?<remainder>.*?))?\Z/
			
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
