# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

module Decode
	# Represents a location in a source file.
	class Location < Struct.new(:path, :line)
		# Generate a string representation of the location.
		def to_s
			"#{path}:#{line}"
		end
	end
end
