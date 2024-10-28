# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative "reference"
require_relative "../documentation"

module Decode
	module Language
		class Generic
			EXTENSIONS = []
			
			TAGS = Comment::Tags.build do |tags|
				tags["attribute"] = Comment::Attribute
				tags["parameter"] = Comment::Parameter
				tags["option"] = Comment::Option
				tags["yields"] = Comment::Yields
				tags["returns"] = Comment::Returns
				tags["raises"] = Comment::Raises
				tags["throws"] = Comment::Throws
				
				tags["deprecated"] = Comment::Pragma
				
				tags["asynchronous"] = Comment::Pragma
				
				tags["public"] = Comment::Pragma
				tags["private"] = Comment::Pragma
			end
			
			def initialize(name, extensions: self.class::EXTENSIONS, tags: self.class::TAGS)
				@name = name
				@extensions = extensions
				@tags = tags
			end
			
			attr :name
			
			def names
				[@name]
			end
			
			attr :extensions
			
			attr :tags
			
			# Generate a language-specific reference.
			# @parameter identifier [String] A valid identifier.
			def reference_for(identifier)
				Reference.new(identifier, self)
			end
			
			def parser
				nil
			end
			
			# Parse the input yielding definitions.
			# @parameter source [Source] The input source file which contains the source code.
			# @yields {|definition| ...} Receives the definitions extracted from the source code.
			# 	@parameter definition [Definition] The source code definition including methods, classes, etc.
			# @returns [Enumerator(Segment)] If no block given.
			def definitions_for(source, &block)
				if parser = self.parser
					parser.definitions_for(source, &block)
				end
			end
			
			# Parse the input yielding segments.
			# Segments are constructed from a block of top level comments followed by a block of code.
			# @parameter source [Source] The input source file which contains the source code.
			# @yields {|segment| ...}
			# 	@parameter segment [Segment]
			# @returns [Enumerator(Segment)] If no block given.
			def segments_for(source, &block)
				if parser = self.parser
					parser.segments_for(source, &block)
				end
			end
		end
	end
end
