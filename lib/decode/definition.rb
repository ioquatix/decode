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

require_relative 'symbol'

module Decode
	# A symbol with attached documentation.
	class Definition < Symbol
		def initialize(kind, name, comments, **options)
			super(kind, name, **options)
			
			@comments = comments
			@documentation = nil
		end
		
		# The comment lines which directly preceeded the definition.
		# @attr [Array(String)]
		attr :comments
		
		# A short form of the definition.
		# e.g. `def short_form`.
		#
		# @return [String | nil]
		def short_form
		end
		
		# A long form of the definition.
		# e.g. `def initialize(kind, name, comments, **options)`.
		#
		# @return [String | nil]
		def long_form
			self.short_form
		end
		
		# A long form which uses the qualified name if possible.
		# Defaults to {long_form}.
		#
		# @return  [String | nil]
		def qualified_form
			self.long_form
		end
		
		# The full text of the definition.
		#
		# @return [String | nil]
		def text
		end
		
		# Whether this definition can contain nested definitions.
		#
		# @return [Boolean]
		def container?
			false
		end
		
		# Whether this represents a single entity to be documented (along with it's contents).
		#
		# @return [Boolean]
		def nested?
			container?
		end
		
		# Structured access to the definitions comments.
		#
		# @return [Documentation | Nil] A `Documentation` if this definition has comments.
		def documentation
			if @comments&.any?
				@documentation ||= Documentation.new(@comments)
			end
		end
	end
end
