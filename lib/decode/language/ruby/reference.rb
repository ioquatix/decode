# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "../reference"

module Decode
	module Language
		module Ruby
			# An Ruby-specific reference which can be resolved to zero or more definitions.
			class Reference < Language::Reference
				def self.from_const(node, language)
					lexical_path = append_const(node)
					
					return self.new(node.location.slice, language, lexical_path)
				end
				
				def self.append_const(node, path = [])
					case node.type
					when :constant_read_node
						path << [nil, node.name.to_s]
					when :constant_path_node
						if node.parent
							append_const(node.parent, path)
							path << ["::", node.name.to_s]
						else
							path << [nil, node.name.to_s]
						end
					when :call_node
						# For call nodes like Tuple(...), treat them as constant references
						if node.receiver.nil?
							path << [nil, node.name.to_s]
						else
							append_const(node.receiver, path)
							path << [".", node.name.to_s]
						end
					else
						raise ArgumentError, "Could not determine reference for #{node.type}!"
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
