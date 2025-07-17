# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

# Base animal class.
class Animal
	# Make the animal speak.
	def speak
		puts "Animal speaks"
	end
end

# A dog is a type of animal.
class Dog < Animal
	# Dogs bark.
	def speak
		puts "Woof!"
	end
	
	# Dogs can fetch.
	def fetch
		puts "Fetching!"
	end
end
