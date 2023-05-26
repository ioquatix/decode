# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020, by Samuel Williams.

# @scope Foo Bar
# @name local
add(:local) do
	# The default hostname for the connection.
	# @name hostname
	# @attribute [String]
	hostname "localhost"
	
	# The default context for managing the connection.
	# @attribute [Context]
	context {Context.new(hostname)}
end
