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
	class Source
		def self.for?(path)
			if language = Language.detect(path)
				self.new(path, language)
			end
		end
		
		def initialize(path, language = nil)
			@path = path
			@language = language || Language.detect(path)
		end
		
		attr :path
		
		attr :language
		
		def open(&block)
			File.open(@path, &block)
		end
		
		def definitions(&block)
			return to_enum(:definitions) unless block_given?
			
			self.open do |file|
				@language.definitions_for(file, &block)
			end
		end
		
		def segments(&block)
			return to_enum(:segments) unless block_given?
			
			self.open do |file|
				@language.segments_for(file, &block)
			end
		end
	end
end
