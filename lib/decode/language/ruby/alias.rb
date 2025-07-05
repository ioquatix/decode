# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "definition"

module Decode
	module Language
		module Ruby
			# Represents an alias statement, e.g., `alias new_name old_name` or `alias_method :new_name, :old_name`
			class Alias < Definition
				def initialize(new_name, old_name, **options)
					super(new_name, **options)
					@old_name = old_name
				end
				
				attr :old_name
				
				def short_form
					"alias #{self.name} #{@old_name}"
				end
				
				def long_form
					"alias #{self.name} #{@old_name}"
				end
				
				def to_s
					"#{self.class.name} #{self.name} -> #{@old_name}"
				end
			end
		end
	end
end
