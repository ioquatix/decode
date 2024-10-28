# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "decode/source"
require "decode/language/ruby"

describe Decode::Comment::Yields do
	let(:language) {Decode::Language::Ruby.new}
	let(:source) {Decode::Source.new(path, language)}
	let(:documentation) {source.segments.first.documentation}
	
	with "nested parameters" do
		let(:path) {File.expand_path(".fixtures/yields.rb", __dir__)}
		
		it "should have yields node with nested parameter nodes" do
			expect(documentation.children[0]).to be_a(Decode::Comment::Yields)
			expect(documentation.children[0]).to have_attributes(
				block: be == "{|item| ...}",
				text: be == ["The items if a block is given."],
			)
			
			parameter = documentation.children[0].children[1]
			expect(parameter).to be_a(Decode::Comment::Parameter)
			expect(parameter).to have_attributes(
				type: be == "Integer",
			)
		end
	end
end
