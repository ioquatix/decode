# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020, by Samuel Williams.

require_relative 'attribute'

module Decode
	module Comment
		# Describes a return value.
		#
		# - `@returns [Integer] The person's age.`
		#
		class Returns < Attribute
		end
	end
end
