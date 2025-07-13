# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

class Test
	def original_method
		puts "original"
	end
	
	alias new_method original_method
	alias_method :another_method, :original_method
	
	private
	
	def private_original
		puts "private original"
	end
	
	private
	alias private_alias private_original
	alias_method :private_alias_method, :private_original
end
