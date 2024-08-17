# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative 'language/generic'
require_relative 'language/ruby'

module Decode
	# A context for looking up languages based on file extension or name.
	class Languages
		def self.all
			self.new.tap do |languages|
				languages.add(Language::Ruby.new)
			end
		end
		
		def initialize
			@named = {}
			@extensions = {}
		end
		
		def freeze
			return unless frozen?
			
			@named.freeze
			@extensions.freeze
			
			super
		end
		
		def add(language)
			language.names.each do |name|
				@named[name] = language
			end
			
			language.extensions.each do |extension|
				@extensions[extension] = language
			end
		end
		
		def fetch(name)
			@named.fetch(name) do
				unless @named.frozen?
					@named[name] = Language::Generic.new(name)
				end
			end
		end
		
		def source_for(path)
			extension = File.extname(path)
			
			if language = @extensions[extension]
				Source.new(path, language)
			end
		end
		
		REFERENCE = /\A(?<name>[a-z]+)?\s+(?<identifier>.*?)\z/
		
		# Parse a language agnostic reference:
		# e.g. `ruby MyModule::MyClass`
		#
		def parse_reference(text, default_language: nil)
			if match = REFERENCE.match(text)
				language = self.fetch(match[:name]) || default_language
				
				return language.reference_for(match[:identifier])
			elsif default_language
				return default_language.reference_for(text)
			end
		end
		
		def reference_for(name, identifier)
			self.fetch(name).reference_for(identifier)
		end
	end
end
