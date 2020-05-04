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
		module Ruby
			# An Ruby-specific reference which can be resolved to zero or more symbols.
			class Reference
				KIND =  {
					':' => :def,
					'.' => :defs,
				}.freeze
				
				# Initialize the reference.
				# @param value [String] The string value of the reference.
				def initialize(value)
					@value = value
					
					@path = nil
					@kind = nil
				end
				
				# Whether the reference starts at the base of the lexical tree.
				def absolute?
					@value.start_with?('::')
				end
				
				METHOD = /\A(?<scope>.*?)?(?<kind>:|\.)(?<name>.+?)\z/
				
				# The lexical path of the reference.
				# @return [Array(String)]
				def path
					if @path.nil?
						@path = @value.split(/::/)
						
						if last = @path.pop
							if match = last.match(METHOD)
								@kind = KIND[match[:kind]]
								
								if scope = match[:scope]
									@path << scope
								end
								
								@path << match[:name]
							else
								@path << last
							end
						end
						
						@path = @path.map(&:to_sym)
						@path.freeze
					end
					
					return @path
				end
				
				# The kind of symbol to match.
				def kind
					self.path
					
					return @kind
				end
			end
		end
	end
end
