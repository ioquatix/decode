# This file is used to test extraction of definitions from unless/else branches.

def foo
end

unless RUBY_VERSION < "3.0"
	def bar
	end
else
	def baz
	end
end
