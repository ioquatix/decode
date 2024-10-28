# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "decode/source"
require "decode/language/ruby"

describe Decode::Comment::Parameter do
	let(:language) {Decode::Language::Ruby.new}
	let(:source) {Decode::Source.new(path, language)}
	let(:documentation) {source.segments.first.documentation}
	
	with "simple parameters" do
		let(:path) {File.expand_path(".fixtures/parameters.rb", __dir__)}
		
		it "should have parameter nodes" do
			expect(documentation.children[0]).to be_a(Decode::Comment::Parameter)
			expect(documentation.children[0]).to have_attributes(
				type: be == "Integer",
				text: be == ["The x co-ordinate."],
			)
			
			expect(documentation.children[1]).to be_a(Decode::Comment::Parameter)
			expect(documentation.children[1]).to have_attributes(
				type: be == "Integer",
				text: be == ["The y co-ordinate."],
			)
		end
	end
end
