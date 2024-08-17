# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require_relative 'language'

module Decode
	# Represents a source file in a specific language.
	class Source
		def initialize(path, language)
			@path = path
			@buffer = nil
			@language = language
		end
		
		# The path of the source file.
		# @attribute [String] A file-system path.
		attr :path
		
		# The relative path of the source, if it is known.
		def relative_path
			if @path.respond_to?(:relative_path)
				@path.relative_path
			else
				@path
			end
		end
		
		# The language of the source file.
		# @attribute [Language::Generic]
		attr :language
		
		# Read the source file into an internal buffer/cache.
		# @returns [String]
		def read
			@buffer ||= File.read(@path).freeze
		end
		
		# Open the source file and read all definitions.
		# @yields {|definition| ...} All definitions from the source file.
		# 	@parameter definition [Definition]
		# @returns [Enumerator(Definition)] If no block given.
		def definitions(&block)
			return to_enum(:definitions) unless block_given?
			
			@language.definitions_for(self, &block)
		end
		
		# Open the source file and read all segments.
		# @yields {|segment| ...} All segments from the source file.
		# 	@parameter segment [Segment]
		# @returns [Enumerator(Segment)] If no block given.
		def segments(&block)
			return to_enum(:segments) unless block_given?
			
			@language.segments_for(self, &block)
		end
		
		def code(index = nil, relative_to: nil)
			@language.code_for(self.read, index, relative_to: relative_to)
		end
	end
end
