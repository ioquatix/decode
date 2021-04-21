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

require_relative 'comment/node'

require_relative 'comment/tags'
require_relative 'comment/attribute'
require_relative 'comment/parameter'
require_relative 'comment/pragma'
require_relative 'comment/raises'
require_relative 'comment/returns'
require_relative 'comment/throws'
require_relative 'comment/yields'

module Decode
	# Structured access to a set of comment lines.
	class Documentation < Comment::Node
		# Initialize the documentation with an array of comments, within a specific language.
		#
		# @parameter comments [Array(String)] An array of comment lines.
		# @parameter language [Language] The language in which the comments were extracted.
		def initialize(comments, language = nil)
			@comments = comments
			@language = language
			
			language.tags.parse(@comments.dup) do |node|
				self.add(node)
			end
		end
		
		# The underlying comments from which the documentation is extracted.
		# @attribute [Array(String)]
		attr :comments
		
		# The language in which the documentation was extracted from.
		# @attribute [Language::Generic]
		attr :language
	end
end
