# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "ruby/generic"

module Decode
	module Language
		# An interface for extracting information from Ruby source code.
		module Ruby
			def self.new
				Generic.new("ruby")
			end
		end
	end
end
