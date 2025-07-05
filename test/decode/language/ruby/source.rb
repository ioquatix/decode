# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "decode/language/ruby"
require "decode/source"

describe Decode::Language::Ruby do
	let(:language) {Decode::Language::Ruby.new}
	
	with "source tracking" do
		let(:source) {Decode::Source.new("test/decode/language/ruby/.fixtures/classes.rb", language)}
		
		it "should attach source to all definitions" do
			definitions = language.definitions_for(source).to_a
			
			definitions.each do |definition|
				expect(definition.source).to be == source
			end
		end
		
		it "should provide correct location information" do
			definitions = language.definitions_for(source).to_a
			
			# Find a class definition
			class_def = definitions.find do |definition|
				definition.is_a?(Decode::Language::Ruby::Class)
			end
			expect(class_def).not.to be_nil
			expect(class_def.location).not.to be_nil
			expect(class_def.location.line).to be > 0
		end
		
		it "should handle nested definitions with correct source" do
			# Use the existing nested modules fixture
			source = Decode::Source.new("test/decode/language/ruby/.fixtures/nested_modules.rb", language)
			definitions = language.definitions_for(source).to_a
			
			# All definitions should have the same source
			definitions.each do |definition|
				expect(definition.source).to be == source
			end
		end
	end
end
