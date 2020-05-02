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

require_relative 'ruby/reference'
require_relative 'ruby/parser'

module Decode
	module Language
		module Ruby
			def self.parse(input, &block)
				Parser.new.parse(input, &block)
			end
			
			# The symbol which is used to separate the specified definition from the parent scope.
			PREFIX = {
				class: '::',
				module: '::',
				def: ':',
				constant: '::',
				defs: '.',
			}.freeze
			
			def self.join(symbols, absolute = true)
				buffer = String.new
				
				symbols.each do |symbol|
					if absolute == false
						absolute = true
					else
						buffer << PREFIX[symbol.kind]
					end
					
					buffer << symbol.name.to_s
				end
				
				return buffer
			end
			
			def self.reference(value)
				Reference.new(value)
			end
		end
	end
end
