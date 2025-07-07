#!/usr/bin/env ruby
# frozen_string_literal: true

# This is a file header comment
# that should NOT be included in method documentation.

# This is a separate comment block
# that should also NOT be included.

# This is the actual method comment
# that SHOULD be included.
def documented_method
	puts "Hello"
end

# This is another method comment
def another_method
	puts "World"
end
