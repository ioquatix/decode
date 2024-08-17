# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative 'node'

module Decode
	module Comment
		# A structured comment.
		class Text
			def initialize(line)
				@line = line
			end
			
			attr :line
			
			def traverse
			end
		end
	end
end
