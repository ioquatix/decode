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
	# Structured access to a set of comment lines.
	class Documentation
		# Initialize the documentation with an array of comments, within a specific language.
		#
		# @param comments [Array(String)] An array of comment lines.
		# @param language [Language] The language in which the comments were extracted.
		def initialize(comments, language = nil)
			@comments = comments
			@language = language
		end
		
		# The language in which the documentation was extracted from.
		attr :language
		
		DESCRIPTION = /\A\s*([^@\s].*)?\z/
		
		# The text-only lines of the comment block.
		#
		# @yield [String]
		# @return [Enumerable]
		def description
			return to_enum(:description) unless block_given?
			
			# We track empty lines and only yield a single empty line when there is another line of text:
			gap = false
			
			@comments.each do |comment|
				if match = comment.match(DESCRIPTION)
					if match[1]
						if gap
							yield ""
							gap = false
						end
						
						yield match[1]
					else
						gap = true
					end
				else
					break
				end
			end
		end
		
		ATTRIBUTE = /\A\s*@(?<name>.*?)\s+(?<value>.*?)\z/
		
		# The attribute lines of the comment block.
		# e.g. `@return [String]`.
		#
		# @yield [String]
		# @return [Enumerable]
		def attributes
			return to_enum(:attributes) unless block_given?
			
			@comments.each do |comment|
				if match = comment.match(ATTRIBUTE)
					yield match
				end
			end
		end
		
		PARAMETER = /\A\s*@param\s+(?<name>.*?)\s+\[(?<type>.*?)\]\s+(?<details>.*?)\z/
		
		# The parameter lines of the comment block.
		# e.g. `@param value [String] The value.`
		#
		# @yield [String]
		# @return [Enumerable]
		def parameters
			return to_enum(:parameters) unless block_given?
			
			@comments.each do |comment|
				if match = comment.match(PARAMETER)
					yield match
				end
			end
		end
	end
end
