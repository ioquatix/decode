class Foo
	def my_public_method
	end
	
	private
	
	def my_private_method
	end
	
	class Nested
	end
	
	private_constant :Nested
end
