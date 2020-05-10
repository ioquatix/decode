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
			
			def self.names
				[self.name]
			end
			
			def self.extensions
				['.rb', '.ru']
			end
			
			# Generate a language-specific reference.
			# @param identifier [String] A valid identifier.
			def self.reference_for(identifier)
				Reference.new(identifier, self)
			end
			
			# Parse the input yielding definitions.
			# @param input [File] The input file which contains the source code.
			# @block {|definition| ...} Receives the definitions extracted from the source code.
			# @yield definition [Definition] The source code definition including methods, classes, etc.
			# @returns [Enumerator(Segment)] If no block given.
			def self.definitions_for(input, &block)
				Parser.new.definitions_for(input, &block)
			end
			
			# Parse the input yielding segments.
			# Segments are constructed from a block of top level comments followed by a block of code.
			# @param input [File] The input file which contains the source code.
			# @block {|segment| ...}
			# @yield segment [Segment]
			# @return [Enumerator(Segment)] If no block given.
			def self.segments_for(input, &block)
				Parser.new.segments_for(input, &block)
			end
		end
	end
end
