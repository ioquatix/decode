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
				
				def nested_name
					"::#{name}"
				end
				
				# The short form of the module.
				# e.g. `module Barnyard`.
				def short_form
					"module #{path_name.last}"
				end
				
				def long_form
					qualified_form
				end
				
				# The fully qualified name of the class.
				# e.g. `module ::Barnyard::Dog`.
				def qualified_form
					"module #{self.qualified_name}"
				end
				
				def path_name
					@name.to_s.split("::").map(&:to_sym)
				end
			end
		end
	end
end
