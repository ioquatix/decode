
# @scope Foo Bar
# @name local
add(:local) do
	# The default hostname for the connection.
	# @name hostname
	# @attr [String]
	hostname "localhost"
	
	# The default context for managing the connection.
	# @attr [Context]
	context {Context.new(hostname)}
end
