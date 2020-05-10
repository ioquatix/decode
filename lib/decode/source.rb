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

require_relative 'language'

module Decode
	# Represents a source file in a specific language.
	class Source
		def initialize(path, language)
			@path = path
			@language = language
		end
		
		# The path of the source file.
		# @attribute [String] A file-system path.
		attr :path
		
		# The language of the source file.
		# @attribute [Language::Generic]
		attr :language
		
		# Open the source file for reading.
		# @yields {|file| ...} The opened {File} instance.
		# 	@parameter file [File]
		def open(&block)
			File.open(@path, &block)
		end
		
		# Open the source file and read all definitions.
		# @yields {|definition| ...} All definitions from the source file.
		# 	@parameter definition [Definition]
		# @returns [Enumerator(Definition)] If no block given.
		def definitions(&block)
			return to_enum(:definitions) unless block_given?
			
			self.open do |file|
				@language.definitions_for(file, &block)
			end
		end
		
		# Open the source file and read all segments.
		# @yields {|segment| ...} All segments from the source file.
		# 	@parameter segment [Segment]
		# @returns [Enumerator(Segment)] If no block given.
		def segments(&block)
			return to_enum(:segments) unless block_given?
			
			self.open do |file|
				@language.segments_for(file, &block)
			end
		end
	end
end
