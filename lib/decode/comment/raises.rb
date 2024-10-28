# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "attribute"

module Decode
	module Comment
		# Identifies that a method might raise an exception.
		#
		# - `@raises [ArgumentError] If the argument cannot be coerced.`
		#
		class Raises < Attribute
		end
	end
end
