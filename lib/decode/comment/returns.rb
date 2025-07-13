# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2025, by Samuel Williams.

require_relative "attribute"

module Decode
	module Comment
		# Represents a return value.
		#
		# Example: `@returns [Integer] The person's age.`
		class Returns < Attribute
		end
	end
end
