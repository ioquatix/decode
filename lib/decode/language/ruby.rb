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
		# The Ruby language.
		module Ruby
			# The canoical name of the language for use in output formatting.
			# e.g. source code highlighting.
			def self.name
				"ruby"
			end
			
			# The symbol which is used to separate the specified definition from the parent scope.
			PREFIX = {
				class: '::',
				module: '::',
				def: ':',
				constant: '::',
				defs: '.',
			}.freeze
			
			# Generate a language-specific fully qualified name.
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
			
			# Generate a language-specific reference.
			def self.reference(value)
				Reference.new(value)
			end
			
			# Parse the input yielding symbols.
			# @block `{|definition| ...}`
			# @yield definition [Definition]
			def self.symbols_for(input, &block)
				Parser.new.symbols_for(input, &block)
			end
			
			# Parse the input yielding interleaved comments and code segments.
			# @block `{|segment| ...}`
			# @yield segment [Segment]
			def self.segments_for(input, &block)
				Parser.new.segments_for(input, &block)
			end
		end
	end
end
