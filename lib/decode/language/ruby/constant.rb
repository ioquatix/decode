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

require_relative 'definition'

module Decode
	module Language
		module Ruby
			# A Ruby-specific constant.
			class Constant < Definition
				# The short form of the constant.
				# e.g. `NAME`.
				def short_form
					@node.location.name.source
				end
				
				def nested_name
					"::#{@name}"
				end
				
				# The long form of the constant.
				# e.g. `NAME = "Alice"`.
				def long_form
					if @node.location.line == @node.location.last_line
						@node.location.expression.source
					elsif @node.children[2].type == :array
						"#{@name} = [...]"
					elsif @node.children[2].type == :hash
						"#{@name} = {...}"
					else
						self.short_form
					end
				end
			end
		end
	end
end