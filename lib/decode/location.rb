# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

module Decode
	class Location < Struct.new(:path, :line)
		def to_s
			"#{path}:#{line}"
		end
	end
end
