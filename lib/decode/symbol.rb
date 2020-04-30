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

module Decode
	class Symbol
		def initialize(kind, name, parent: nil, language: parent.language)
			@kind = kind
			@name = name
			@parent = parent
			@language = language
		end
		
		attr :kind
		attr :name
		attr :parent
		attr :language
		
		def full_name(parts = [])
			if @parent
				@parent.full_name(parts)
			end
			
			parts << self
			
			@language.join(parts)
		end
	end
	
	class Declaration < Symbol
		def initialize(kind, name, text, comments, **options)
			super(kind, name, **options)
			
			@text = text
			@comments = comments
		end
		
		attr :text
		attr :comments
	end
end
