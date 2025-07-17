# frozen_string_literal: true

module Decode
	module RBS
		class Method
			def initialize(definition)
				@definition = definition
				@signatures = nil
			end
			
			def signatures
				@signatures ||= extract_signatures
			end
			
			private
			
			def extract_tags
				@definition.documentation.children.select do |child|
					child.is_a?(Comment::RBS)
				end
			end
			
			def extract_signatures
				extract_tags.select(&:method_signature?).map(&:method_signature)
			end
		end
	end
end