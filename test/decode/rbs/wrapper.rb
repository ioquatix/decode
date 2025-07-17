# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "decode/language/ruby"
require "decode/rbs/wrapper"
require "decode/definition"
require "decode/documentation"
require "decode/comment/rbs"

describe Decode::RBS::Wrapper do
	let(:language) {Decode::Language::Ruby.new}
	let(:comments) {[]}
	let(:definition) {Decode::Language::Ruby::Class.new([:TestClass], comments: comments, language: language)}
	let(:wrapper) {subject.new(definition)}
	
	with "#initialize" do
		it "initializes with definition" do
			expect(wrapper.instance_variable_get(:@definition)).to be == definition
			expect(wrapper.instance_variable_get(:@tags)).to be_nil
		end
	end
	
	with "#tags" do
		with "definition without documentation" do
			it "returns empty array when no documentation" do
				expect(wrapper.tags).to be == []
			end
		end
		
		with "definition with documentation containing RBS tags" do
			let(:comments) {["@rbs generic T"]}
			
			it "extracts RBS tags from documentation" do
				expect(wrapper.tags).to have_value(be_a(Decode::Comment::RBS))
			end
		end
		
		with "definition with documentation containing mixed tags" do
			let(:comments) {["Some text", "@rbs generic T"]}
			
			it "filters only RBS tags" do
				wrapper.tags.each do |tag|	
					expect(tag).to be_a(Decode::Comment::RBS)
				end
			end
		end
	end
end
