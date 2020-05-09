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
	# Structured access to a set of comment lines.
	class Documentation
		# Initialize the documentation with an array of comments, within a specific language.
		#
		# @param comments [Array(String)] An array of comment lines.
		# @param language [Language] The language in which the comments were extracted.
		def initialize(comments, language = nil)
			@comments = comments
			@language = language
		end
		
		# The underlying comments from which the documentation is extracted.
		# @attr [Array(String)]
		attr :comments
		
		# The language in which the documentation was extracted from.
		# @attr [Language]
		attr :language
		
		DESCRIPTION = /\A\s*([^@\s].*)?\z/
		
		# The text-only lines of the comment block.
		#
		# @yield [String]
		# @return [Enumerable]
		def description
			return to_enum(:description) unless block_given?
			
			# We track empty lines and only yield a single empty line when there is another line of text:
			gap = false
			
			@comments.each do |comment|
				if match = comment.match(DESCRIPTION)
					if match[1]
						if gap
							yield ""
							gap = false
						end
						
						yield match[1]
					else
						gap = true
					end
				else
					break
				end
			end
		end
		
		# Describes a named method parameter.
		#
		# - `@param age [Float] The users age.`
		#
		PARAMETER = /\A\s*@(?<directive>param(eter)?)\s+(?<name>.*?)\s+\[(?<type>.*?)\](\s+(?<details>.*?))?\Z/
		
		# Describes a block parameter.
		#
		# - `@block {|person| ... } If a block is given.`
		#
		BLOCK = /\A\s*@(?<directive>block)\s+(?<type>{.*?})(\s+(?<details>.*?))?\Z/
		
		# Describes a named yield parameter.
		#
		# - `@yields person [Person] A person instance.`
		#
		YIELDS = /\A\s*@(?<directive>yields?)\s+(?<name>.*?)\s+\[(?<type>.*?)\](\s+(?<details>.*?))?\Z/
		
		# Describes an attribute type.
		#
		# - `@attribute [Integer] The person's age.`
		#
		ATTRIBUTE = /\A\s*@(?<directive>attr(ibute)?)\s+\[(?<type>.*?)\](\s+(?<details>.*?))?\Z/
		
		# Describes a return value.
		#
		# - `@returns [Integer] The person's age.`
		#
		RETURNS = /\A\s*@(?<directive>returns?)\s+\[(?<type>.*?)\](\s+(?<details>.*?))?\Z/
		
		# Identifies that a method might throw.
		#
		# - `@throws [:skip] If the `
		#
		THROWS = /\A\s*@(?<directive>throws?)\s+\[(?<type>.*?)\](\s+(?<details>.*?))?\Z/
		
		# Identifies that a mathod might raise an exception.
		#
		# - `@raises [exception] details`
		#
		RAISES = /\A\s*@(?<directive>raises?)\s+\[(?<type>.*?)\](\s+(?<details>.*?))?\Z/
		
		# Asserts a specific property about the method signature.
		#
		# - `@reentrant This method is thread-safe.`
		# - `@deprecated Please use {other_method} instead.`
		# - `@blocking This method may block.`
		# - `@asynchronous This method may yield.`
		#
		PRAGMA = /\A\s*@(?<directive>reentrant|deprecated|blocking|asynchronous)(\s+(?<details>.*?))?\Z/
		
		# Scans the comments for matching signature patterns.
		# @block {|kind, match| ... } If a block is given.
		# @yield kind [Symbol] The kind of directive that was parsed.
		# @yield match [MatchData] The extracted parts of the directive.
		# @returns [Enumerator] If no block was given.
		def signature
			return to_enum(:signature) unless block_given?
			
			@comments.each do |comment|
				if match = comment.match(PARAMETER)
					yield :parameter, match
				elsif match = comment.match(BLOCK)
					yield :block, match
				elsif match = comment.match(YIELDS)
					yield :yields, match
				elsif match = comment.match(ATTRIBUTE)
					yield :attribute, match
				elsif match = comment.match(RETURNS)
					yield :returns, match
				elsif match = comment.match(THROWS)
					yield :returns, match
				elsif match = comment.match(RAISES)
					yield :returns, match
				elsif match = comment.match(PRAGMA)
					yield :pragma, match
				end
			end
		end
	end
end
