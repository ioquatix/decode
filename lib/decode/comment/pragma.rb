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

require_relative 'tag'

module Decode
	module Comment
		# Asserts a specific property about the method signature.
		#
		# - `@reentrant This method is thread-safe.`
		# - `@deprecated Please use {other_method} instead.`
		# - `@blocking This method may block.`
		# - `@asynchronous This method may yield.`
		#
		class Pragma < Tag
			def self.parse(directive, text, lines, tags, level = 0)
				self.build(directive, text)
			end
			
			def self.build(directive, text)
				node = self.new(directive)
				
				if text
					node.add(Text.new(text))
				end
				
				return node
			end
			
			def initialize(directive)
				super(directive)
			end
		end
	end
end
