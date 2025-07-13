# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

module IfElseMethods
	if true
		def method_in_if
		end
	else
		def method_in_else
		end
	end

	if false
		def method_in_if_false
		end
	elsif true
		def method_in_elsif
		end
	else
		def method_in_final_else
		end
	end
end
