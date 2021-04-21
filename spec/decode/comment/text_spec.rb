# Copyright, 2020, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'decode/source'
require 'decode/language/ruby'

RSpec.describe Decode::Comment::Text do
	let(:language) {Decode::Language::Ruby.new}
	let(:source) {Decode::Source.new(path, language)}
	let(:documentation) {source.segments.first.documentation}
	
	context 'with nested text nodes' do
		let(:path) {File.expand_path("fixtures/text.rb", __dir__)}
		
		it "should have text nodes" do
			expect(documentation.children[0]).to be_kind_of(Decode::Comment::Text)
			expect(documentation.children[0]).to have_attributes(
				line: "Iterates over all the items."
			)
			
			yields = documentation.children[1]
			expect(yields).to be_kind_of(Decode::Comment::Yields)
			expect(yields.children[0]).to be_kind_of(Decode::Comment::Text)
			expect(yields.children[0]).to have_attributes(
				line: "The items if a block is given."
			)
			
			parameter = yields.children[2]
			expect(parameter).to be_kind_of(Decode::Comment::Parameter)
			
			expect(parameter.children[0]).to be_kind_of(Decode::Comment::Text)
			expect(parameter.children[0]).to have_attributes(
				line: "The item will always be negative."
			)
		end
		
		it "can extract top level text" do
			expect(documentation.text).to be == [
				"Iterates over all the items.",
				"For more details see {Array}.",
			]
		end
	end
end
