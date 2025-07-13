# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2025, by Samuel Williams.

require_relative "ruby/generic"

module Decode
	module Language
		# Represents an interface for extracting information from Ruby source code.
		module Ruby
			# Create a new Ruby language instance.
			# @returns [Ruby::Generic] A configured Ruby language parser.
			def self.new
				Generic.new("ruby")
			end
		end
	end
end
