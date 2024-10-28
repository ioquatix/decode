# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "attribute"

module Decode
	module Comment
		# Identifies that a method might throw a specific symbol.
		#
		# - `@throws [:skip] To skip recursion.`
		#
		class Throws < Attribute
		end
	end
end
