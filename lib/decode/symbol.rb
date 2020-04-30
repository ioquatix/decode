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
	Key = Struct.new(:kind, :name)
	
	class Symbol
		def initialize(kind, name, parent: nil, language: parent.language)
			@kind = kind
			@name = name
			@parent = parent
			@language = language
			
			@path = nil
			@qualified_name = nil
		end
		
		def key
			Key.new(@kind, @name)
		end
		
		def inspect
			"\#<#{self.class} #{@kind} #{qualified_name}>"
		end
		
		attr :kind
		attr :name
		attr :parent
		attr :language
		
		def qualified_name
			@qualified_name ||= @language.join(self.path).freeze
		end
		
		def path
			if @path
				@path
			elsif @parent
				@path = [*@parent.path, self.key]
			else
				@path = [self.key]
			end
		end
		
		def lexical_path
			self.path.map(&:name)
		end
	end
	
	class Definition < Symbol
		def initialize(kind, name, node, comments, **options)
			super(kind, name, **options)
			
			@node = node
			@comments = comments
			@documentation = nil
		end
		
		def text
			@node.location.expression.source
		end
		
		attr :comments
		
		def documentation
			if @comments.any?
				@documentation ||= Documentation.new(@comments)
			end
		end
	end
end
