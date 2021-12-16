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
			# A Ruby-specific module.
			class Module < Definition
				# A module is a container for other definitions.
				def container?
					true
				end
				
				def nested_name
					"::#{name}"
				end
				
				# The short form of the module.
				# e.g. `module Barnyard`.
				def short_form
					"module #{@name}"
				end
				
				# The long form is the same as the short form.
				alias long_form short_form
				
				# The fully qualified name of the class.
				# e.g. `module ::Barnyard::Dog`.
				def qualified_form
					"module #{self.qualified_name}"
				end
			end
		end
	end
end
