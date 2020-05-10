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

require_relative 'node'

module Decode
	module Comment
		class Tag < Node
			def self.parse(directive, text, lines, tags, level = 0)
				if match = self::PATTERN.match(text)
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
