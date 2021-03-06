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

require_relative 'documentation'

module Decode
	# A chunk of code with an optional preceeding comment block.
	#
	#	~~~ ruby
	#	# Get the first segment from a source file:
	#	segment = source.segments.first
	#	~~~
	#
	class Segment
		def initialize(comments, language)
			@comments = comments
			@language = language
		end
		
		# The preceeding comments.
		# @attribute [Array(String)]
		attr :comments
		
		# The language of the code attached to this segment.
		# @attribute [Language::Generic]
		attr :language
		
		# An interface for accsssing the documentation of the definition.
		# @returns [Documentation | nil] A {Documentation} instance if this definition has comments.
		def documentation
			if @comments&.any?
				@documentation ||= Documentation.new(@comments, @language)
			end
		end
		
		# The source code trailing the comments.
		# @returns [String | nil]
		def code
		end
	end
end
