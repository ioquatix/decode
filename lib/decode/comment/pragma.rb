# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative 'tag'

module Decode
	module Comment
		# Asserts a specific property about the method signature.
		#
		# - `@reentrant This method is thread-safe.`
		# - `@deprecated Please use {other_method} instead.`
		# - `@blocking This method may block.`
		# - `@asynchronous This method may yield.`
		#
		class Pragma < Tag
			def self.parse(directive, text, lines, tags, level = 0)
				self.build(directive, text)
			end
			
			def self.build(directive, text)
				node = self.new(directive)
				
				if text
					node.add(Text.new(text))
				end
				
				return node
			end
			
			def initialize(directive)
				super(directive)
			end
		end
	end
end
