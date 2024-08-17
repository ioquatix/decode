# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

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
