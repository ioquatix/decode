# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require 'decode/index'
require 'decode/source'
require 'decode/language/ruby'
require 'decode/syntax/rewriter'

describe Decode::Language::Ruby do
	let(:path) {File.expand_path(".fixtures/types.rb", __dir__)}
	let(:language) {subject.new}
	let(:source) {Decode::Source.new(path, language)}
	let(:index) {Decode::Index.new}
	let(:code) {source.code(index)}
	
	it "can extract some constants" do
		index.update([path])
		
		matches = code.extract
		expect(matches).not.to be(:empty?)
	end
	
	it "can rewrite code" do
		index.update([path])
		
		rewriter = Decode::Syntax::Rewriter.new(code.text)
		
		code.extract(rewriter)
		
		expect(rewriter.apply.join).to be(:include?, "[Tuple]([String], [Integer])")
	end
end
