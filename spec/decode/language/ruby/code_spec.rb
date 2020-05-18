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

require 'decode/index'
require 'decode/source'
require 'decode/language/ruby'
require 'decode/syntax/rewriter'

RSpec.describe Decode::Language::Ruby do
	let(:path) {File.expand_path("fixtures/types.rb", __dir__)}
	let(:source) {Decode::Source.new(path, described_class)}
	let(:index) {Decode::Index.new}
	let(:code) {source.code(index)}
	
	it "can extract some constants" do
		index.update([path])
		
		matches = code.extract
		expect(matches).to_not be_empty
	end
	
	it "can rewrite code" do
		index.update([path])
		
		rewriter = Decode::Syntax::Rewriter.new(code.text)
		
		code.extract(rewriter)
		
		expect(rewriter.apply.join).to include('[Tuple]([String], [Integer])')
	end
end
