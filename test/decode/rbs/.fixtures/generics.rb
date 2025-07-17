# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

# A generic container class.
# @rbs generic T
class Container
	# Create a new container.
	def initialize
		@items = []
	end
	
	# Add an item to the container.
	# @parameter item [T] The item to add.
	def add(item)
		@items << item
	end
	
	# Get the first item.
	# @returns [T | Nil] The first item or nil if empty.
	def first
		@items.first
	end
	
	# Check if the container is empty.
	# @returns [Boolean] True if empty.
	def empty?
		@items.empty?
	end
end
