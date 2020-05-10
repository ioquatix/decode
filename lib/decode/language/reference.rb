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
	module Language
		# An reference which can be resolved to zero or more definitions.
		class Reference
			# Initialize the reference.
			# @parameter identifier [String] The identifier part of the reference.
			def initialize(identifier, language)
				@identifier = identifier
				@language = language
				
				@lexical_path = nil
				@path = nil
			end
			
			def to_s
				"{#{self.language} #{self.identifier}}"
			end
			
			def inspect
				"\#<#{self.class} {#{self.identifier}}>"
			end
			
			# The identifier part of the reference.
			# @attribute [String]
			attr :identifier
			
			# The language associated with this reference.
			# @attribute [Language::Generic]
			attr :language
			
			# Whether the reference starts at the base of the lexical tree.
			def absolute?
				!self.relative?
			end
			
			def relative?
				prefix, name = self.lexical_path.first
				
				return prefix.nil?
			end
			
			def split(identifier)
				identifier.scan(/(\W+)?(\w+)/)
			end
			
			def lexical_path
				@lexical_path ||= self.split(@identifier)
			end
			
			def best(definitions)
				prefix, name = lexical_path.last
				
				definitions.select do |definition|
					definition.language == @language && (
						prefix.nil? || definition.start_with?(prefix)
					)
				end
			end
			
			# The lexical path of the reference.
			# @returns [Array(String)]
			def path
				@path ||= self.lexical_path.map{|_, name| name.to_sym}
			end
		end
	end
end
