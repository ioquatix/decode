# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2025, by Samuel Williams.

require_relative "language/generic"
require_relative "language/ruby"

module Decode
	# Represents a context for looking up languages based on file extension or name.
	class Languages
		# Create a new languages context with all supported languages.
		# @returns [Languages] A languages context with Ruby support enabled.
		def self.all
			self.new.tap do |languages|
				languages.add(Language::Ruby.new)
			end
		end
		
		# Initialize a new languages context.
		def initialize
			@named = {}
			@extensions = {}
		end
		
		# Freeze the languages context to prevent further modifications.
		def freeze
			return unless frozen?
			
			@named.freeze
			@extensions.freeze
			
			super
		end
		
		# Add a language to this context.
		# @parameter language [Language::Generic] The language to add.
		def add(language)
			# Register by name:
			language.names.each do |name|
				@named[name] = language
			end
			
			# Register by file extension:
			language.extensions.each do |extension|
				@extensions[extension] = language
			end
		end
		
		# Fetch a language by name, creating a generic language if needed.
		# @parameter name [String] The name of the language to fetch.
		# @returns [Language::Generic] The language instance for the given name.
		def fetch(name)
			@named.fetch(name) do
				unless @named.frozen?
					@named[name] = Language::Generic.new(name)
				end
			end
		end
		
		# Create a source object for the given file path.
		# @parameter path [String] The file system path to create a source for.
		# @returns [Source | Nil] A source object if the file extension is supported, nil otherwise.
		def source_for(path)
			extension = File.extname(path)
			
			if language = @extensions[extension]
				Source.new(path, language)
			end
		end
		
		REFERENCE = /\A(?<name>[a-z]+)?\s+(?<identifier>.*?)\z/
		
		# Parse a language agnostic reference.
		# @parameter text [String] The text to parse (e.g., "ruby MyModule::MyClass").
		# @parameter default_language [Language::Generic] The default language to use if none specified.
		# @returns [Language::Reference | Nil] The parsed reference, or nil if parsing fails.
		def parse_reference(text, default_language: nil)
			if match = REFERENCE.match(text)
				language = self.fetch(match[:name]) || default_language
				
				return language.reference_for(match[:identifier])
			elsif default_language
				return default_language.reference_for(text)
			end
		end
		
		# Create a reference for the given language and identifier.
		# @parameter name [String] The name of the language.
		# @parameter identifier [String] The identifier to create a reference for.
		# @returns [Language::Reference] The created reference.
		def reference_for(name, identifier)
			self.fetch(name).reference_for(identifier)
		end
	end
end
