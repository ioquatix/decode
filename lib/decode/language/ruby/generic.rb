# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

require_relative 'reference'
require_relative 'parser'
require_relative 'code'

module Decode
	module Language
		module Ruby
			# The Ruby language.
			class Generic < Language::Generic
				EXTENSIONS = ['.rb', '.ru']
				
				def parser
					@parser ||= Parser.new(self)
				end
				
				# Generate a language-specific reference.
				# @parameter identifier [String] A valid identifier.
				def reference_for(identifier)
					Reference.new(identifier, self)
				end
				
				def code_for(text, index, relative_to: nil)
					Code.new(text, index, relative_to: relative_to, language: self)
				end
			end
		end
	end
end
