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

require_relative '../reference'

module Decode
	module Language
		module Ruby
			# An Ruby-specific reference which can be resolved to zero or more definitions.
			class Reference < Language::Reference
				def self.from_const(node, language)
					lexical_path = append_const(node)
					
					return self.new(node.location.expression.source, language, lexical_path)
				end
				
				def self.append_const(node, path = [])
					parent, name = node.children
					
					if parent and parent.type != :cbase
						append_const(parent, path)
					end
					
					case node.type
					when :const
						if parent && parent.type != :cbase
							path << ['::', name]
						else
							path << [nil, name]
						end
					when :send
						path << ['#', name]
					when :cbase
						# Ignore.
					else
						raise ArgumentError, "Could not determine reference for #{node}!"
					end
					
					return path
				end
				
				def split(text)
					text.scan(/(::|\.|#|:)?([^:.#]+)/)
				end
			end
		end
	end
end
