# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require 'decode/source'
require 'decode/language/ruby'

describe Decode::Comment::Returns do
	let(:language) {Decode::Language::Ruby.new}
	let(:source) {Decode::Source.new(path, language)}
	let(:documentation) {source.segments.first.documentation}
	
	with 'nested parameters' do
		let(:path) {File.expand_path(".fixtures/returns.rb", __dir__)}
		
		it "should have returns node" do
			expect(documentation.children[0]).to be_a(Decode::Comment::Returns)
			expect(documentation.children[0]).to have_attributes(
				type: be == "Integer",
				text: be == ["The number of items."],
			)
		end
	end
end
