# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

class VisibilityTest
	def public_method_1
	end
	
	private def private_method_1
	end
	
	def public_method_2
	end
	
	protected def protected_method_1
	end
	
	def public_method_3
	end
	
	public def public_method_4
	end
	
	# Test standalone modifier after inline
	private
	
	def private_method_2
	end
	
	def private_method_3
	end
	
	protected
	
	def protected_method_2
	end
	
	public
	
	def public_method_5
	end
end
