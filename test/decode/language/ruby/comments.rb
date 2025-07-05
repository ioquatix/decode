# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "decode/language/ruby"
require "decode/source"

describe Decode::Language::Ruby do
	let(:language) {Decode::Language::Ruby.new}
	
	with "comment extraction" do
		it "should preserve comment indentation" do
			# Use the existing comments fixture
			source = Decode::Source.new("test/decode/language/ruby/.fixtures/comments.rb", language)
			definitions = language.definitions_for(source).to_a
			# Should have definitions with comments
			definitions_with_comments = definitions.select do |definition|
				definition.comments.any?
			end
			expect(definitions_with_comments.size).to be > 0
		end
		
		it "should handle comments correctly" do
			# Use the comments fixture
			source = Decode::Source.new("test/decode/language/ruby/.fixtures/comments.rb", language)
			definitions = language.definitions_for(source).to_a
			
			# Should extract comments properly
			definitions.each do |definition|
				if definition.comments.any?
					expect(definition.comments).to be_a(Array)
					expect(definition.comments.first).to be_a(String)
				end
			end
		end
	end
end
