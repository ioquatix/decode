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
			# A Ruby-specific class.
			class Class < Definition
				# A class is a container for other definitions.
				def container?
					true
				end
				
				def nested_name
					"::#{name}"
				end
				
				# The short form of the class.
				# e.g. `class Animal`.
				def short_form
					"class #{@name}"
				end
				
				# The long form of the class.
				# e.g. `class Dog < Animal`.
				def long_form
					if super_node = @node.children[1]
						@node.location.keyword.join(
							super_node.location.expression
						).source
					else
						self.short_form
					end
				end
				
				# The fully qualified name of the class.
				# e.g. `class ::Barnyard::Dog`.
				def qualified_form
					"class #{self.qualified_name}"
				end
			end
			
			# A Ruby-specific singleton class.
			class Singleton < Definition
				# A singleton class is a container for other definitions.
				# @return [Boolean]
				def container?
					true
				end
				
				# Typically, a singleton class does not contain other definitions.
				# @return [Boolean]
				def nested?
					false
				end
				
				# The short form of the class.
				# e.g. `class << (self)`.
				def short_form
					"class << #{@name}"
				end
				
				# The long form is the same as the short form.
				alias long_form short_form
			end
		end
	end
end