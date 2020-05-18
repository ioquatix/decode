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

module Decode
	module Syntax
		class Rewriter
			def initialize(text)
				@text = text
				@matches = []
			end
			
			attr :text
			
			attr :matches
			
			def << match
				@matches << match
			end
			
			# Returns a chunk of raw text with no formatting.
			def text_for(range)
				@text[range]
			end
			
			def apply(output = [])
				offset = 0
				
				@matches.sort.each do |match|
					if match.offset > offset
						output << text_for(offset...match.offset)
						
						offset = match.offset
					elsif match.offset < offset
						# Match intersects last output buffer.
						next
					end
					
					offset += match.apply(output, self)
				end
				
				if offset < @text.size
					output << text_for(offset...@text.size)
				end
				
				return output
			end
			
			def link_to(definition, text)
				"[#{text}]"
			end
		end
	end
end
