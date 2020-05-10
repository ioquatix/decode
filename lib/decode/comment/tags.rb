# Copyright, 2020, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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
						yield Text.new(line.strip)
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
