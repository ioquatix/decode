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
		
		def text_for(range)
			@text[range]
		end
		
		def apply
			output = []
			offset = 0
			
			@matches.sort.each do |match|
				if match.offset > offset
					output << text_for(offset...match.offset)
				end
				
				offset += @match.apply(output, self)
			end
			
			return output.join
		end
	end
	
	class Match
		def initialize(range)
			@range = range
		end
		
		attr :range
		
		def apply(source)
			return source[range]
		end
		
		def <=> other
			@range.min <=> other.range.min
		end
		
		def offset
			@range.min
		end
		
		def size
			@range.size
		end
		
		def apply(output, rewriter)
			output << rewriter.text_for(@range)
			
			return self.size
		end
	end
	
	class Link < Match
		def initialize(range, definition)
			@definition = definition
		end
		
		def apply(output, rewriter)
			output << rewriter.link_to(
				@definition,
				rewriter.text_for(@range)
			)
			
			return self.size
		end
	end
end