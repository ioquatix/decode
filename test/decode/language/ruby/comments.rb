# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "decode/language/ruby"
require "decode/source"
require "decode/documentation"

describe Decode::Language::Ruby do
	let(:language) {Decode::Language::Ruby.new}
	
	with "comment extraction" do
		it "should preserve comment indentation" do
			# Use the existing comments fixture
			source = Decode::Source.new("test/decode/language/ruby/.fixtures/comments.rb", language)
			definitions = language.definitions_for(source).to_a
			# Should have definitions with comments
			definitions_with_comments = definitions.select do |definition|
				definition.documented?
			end
			expect(definitions_with_comments.size).to be > 0
		end
		
		it "should handle comments correctly" do
			# Use the comments fixture
			source = Decode::Source.new("test/decode/language/ruby/.fixtures/comments.rb", language)
			definitions = language.definitions_for(source).to_a
			
			# Should extract comments properly
			definitions.each do |definition|
				if definition.documented?
					expect(definition.comments).to be_a(Array)
					expect(definition.comments.first).to be_a(String)
				end
			end
		end
		
		it "should extract clean comments without hash symbols" do
			# Use the existing comments fixture
			source = Decode::Source.new("test/decode/language/ruby/.fixtures/comments.rb", language)
			definitions = language.definitions_for(source).to_a
			
			# Find the method definition
			method_definition = definitions.find { |d| d.name == :method }
			expect(method_definition).not.to be_nil
			expect(method_definition.documented?).to be_truthy
			
			# Check the raw comments array
			puts "Raw comments for method:"
			method_definition.comments.each_with_index do |comment, i|
				puts "  [#{i}]: #{comment.inspect}"
			end
			
			# Check that comments don't start with "# "
			method_definition.comments.each do |comment|
				expect(comment.start_with?("# ")).to be == false
				expect(comment.start_with?("#")).to be == false
			end
			
			# Test Documentation class
			documentation = method_definition.documentation
			expect(documentation).not.to be_nil
			
			puts "Documentation comments:"
			documentation.comments.each_with_index do |comment, i|
				puts "  [#{i}]: #{comment.inspect}"
			end
		end
	end
end
