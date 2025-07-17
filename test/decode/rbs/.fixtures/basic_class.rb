# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

# A basic class for testing RBS generation.
class Animal
	# Make the animal speak.
	def speak
		puts "Animal speaks"
	end
	
	# Get the animal's name.
	def name
		@name
	end
	
	# Set the animal's name.
	# @parameter name [String] The new name.
	def name=(name)
		@name = name
	end
end
