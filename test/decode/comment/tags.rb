# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

require 'decode/source'
require 'decode/language/ruby'

describe Decode::Comment::Tags do
	let(:language) {Decode::Language::Ruby.new}
	let(:source) {Decode::Source.new(path, language)}
	let(:segments) {source.segments.to_a}
	
	with 'pragmas' do
		let(:path) {File.expand_path(".fixtures/pragmas.rb", __dir__)}
		let(:public_method) {segments[0]}
		let(:private_method) {segments[1]}
		
		it "should have public directive" do
			pragma = public_method.documentation.children.first
			expect(pragma.directive).to be == "public"
		end
		
		it "should have private directive" do
			pragma = private_method.documentation.children.first
			expect(pragma.directive).to be == "private"
		end
	end
end
