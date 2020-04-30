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
require 'build/files/glob'

RSpec.describe Decode::Index do
	let(:path) {File.expand_path("../../lib", __dir__)}
	let(:glob) {Build::Files::Glob.new(path, "**/*.rb")}
	subject(:index) {described_class.new(glob)}
	
	it 'can extract declarations' do
		index.update!
		
		expect(index.symbols).to include(
			"::Decode::Documentation",
			"::Decode::Documentation:initialize",
			"::Decode::Documentation:description",
			"::Decode::Documentation:attributes",
			"::Decode::Documentation:parameters",
			"::Decode::Language",
			"::Decode::Language.detect"
		)
		
		# index.symbols.each do |key, symbol|
		# 	puts "#{key} #{symbol.kind}"
		# 
		# 	if comments = symbol.comments
		# 		comments.each do |line|
		# 			puts line
		# 		end
		# 	end
		# end
	end
	
	describe '#lookup' do
		it 'can lookup relative references' do
			index.update!
			
			initialize_reference = Decode::Language::Ruby::Reference.new("Decode::Documentation:initialize")
			initialize_symbols = index.lookup(initialize_reference)
			expect(initialize_symbols.size).to be == 1
			
			source_reference = Decode::Language::Ruby::Reference.new("Source")
			source_symbols = index.lookup(source_reference, relative_to: initialize_symbols.first)
			expect(source_symbols.size).to be == 1
			expect(source_symbols.first.qualified_name).to be == "::Decode::Source"
		end
	end
end
