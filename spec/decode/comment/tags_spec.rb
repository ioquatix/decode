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

RSpec.describe Decode::Comment::Tags do
	let(:language) {Decode::Language::Ruby.new}
	let(:source) {Decode::Source.new(path, language)}
	let(:segments) {source.segments.to_a}
	
	context 'with pragmas' do
		let(:path) {File.expand_path("fixtures/pragmas.rb", __dir__)}
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
