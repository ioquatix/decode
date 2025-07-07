# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

class MyClass
	# This is a simple method with some indentation
	# @returns [String] A greeting message
	def simple_method
		"Hello World"
	end
	
	# This is a more complex method with multiple lines
	# @parameter name [String] The name to greet
	# @returns [String] A personalized greeting
	def complex_method(name)
		greeting = "Hello"
		message = "#{greeting}, #{name}!"
		
		# Add some extra processing
		if name.length > 5
			message += " You have a long name!"
		end
		
		return message
	end
	
	# A method with a block
	# @yields [String] Each line of the message
	def method_with_block
		lines = [
			"First line",
			"Second line",
			"Third line"
		]
		
		lines.each do |line|
			yield line
		end
	end
end
