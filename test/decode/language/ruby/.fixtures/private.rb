class Foo
	def self.my_public_class_method
	end
	
	def my_public_method
	end
	
	private
	
	def my_private_method
	end
	
	class Nested
		def whatever
		end
	end
	
	private_constant :Nested
end
