# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

module Decode
	module Language
		# An reference which can be resolved to zero or more definitions.
		class Reference
			# Initialize the reference.
			# @parameter identifier [String] The identifier part of the reference.
			def initialize(identifier, language, lexical_path = nil)
				@identifier = identifier
				@language = language
				
				@lexical_path = lexical_path
				@path = nil
			end
			
			def to_s
				"{#{self.language} #{self.identifier}}"
			end
			
			def inspect
				"\#<#{self.class} {#{self.identifier}}>"
			end
			
			# The identifier part of the reference.
			# @attribute [String]
			attr :identifier
			
			# The language associated with this reference.
			# @attribute [Language::Generic]
			attr :language
			
			# Whether the reference starts at the base of the lexical tree.
			def absolute?
				!self.relative?
			end
			
			def relative?
				prefix, name = self.lexical_path.first
				
				return prefix.nil?
			end
			
			def split(identifier)
				identifier.scan(/(\W+)?(\w+)/)
			end
			
			def lexical_path
				@lexical_path ||= self.split(@identifier)
			end
			
			def priority(definition, prefix)
				if prefix.nil?
					return 1
				elsif definition.start_with?(prefix)
					return 0
				else
					return 2
				end
			end
			
			def best(definitions)
				prefix, name = lexical_path.last
				
				first = nil
				without_prefix = nil
				
				definitions.each do |definition|
					first ||= definition
					
					next unless definition.language == @language
					
					if prefix.nil?
						without_prefix ||= definition
					elsif definition.start_with?(prefix)
						return definition
					end
				end
				
				return without_prefix || first
			end
			
			# The lexical path of the reference.
			# @returns [Array(String)]
			def path
				@path ||= self.lexical_path.map{|_, name| name.to_sym}
			end
		end
	end
end
