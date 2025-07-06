# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "definition"

module Decode
	module Language
		module Ruby
			# A Ruby-specific module.
			class Module < Definition
				# A module is a container for other definitions.
				def container?
					true
				end
				
				# The short form of the module.
				# e.g. `module Barnyard`.
				def short_form
					"module #{self.name}"
				end
				
				# Generate a long form representation of the module.
				def long_form
					qualified_form
				end
				
				# The fully qualified name of the module.
				# e.g. `module ::Barnyard::Dog`.
				def qualified_form
					"module #{self.qualified_name}"
				end
			end
		end
	end
end
