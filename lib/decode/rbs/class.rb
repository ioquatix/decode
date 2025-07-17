# frozen_string_literal: true

module Decode
	module RBS
		class Class
			def initialize(definition)
				@definition = definition
				@tags = nil
				@generics = nil
			end
			
			def tags
				@tags ||= extract_tags
			end
			
			def generics
				@generics ||= extract_generics
			end
			
			private
			
			def extract_tags
				@definition.documentation&.children&.select do |child|
					child.is_a?(Comment::RBS)
				end || []
			end
			
			def extract_generics
				tags.select(&:generic?).map(&:generic_parameter)
			end
		end
	end
end