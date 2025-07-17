# frozen_string_literal: true

# A utility module for string operations.
module StringUtils
	# Reverse a string.
	# @parameter str [String] The string to reverse.
	# @returns [String] The reversed string.
	def reverse_string(str)
		str.reverse
	end
	
	# Check if a string is empty.
	# @parameter str [String] The string to check.
	# @returns [Boolean] True if empty.
	def empty?(str)
		str.empty?
	end
end 