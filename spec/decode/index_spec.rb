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
	let(:languages) {subject.languages}
	let(:path) {File.expand_path("../../lib", __dir__)}
	let(:paths) {Build::Files::Glob.new(path, "**/*.rb")}
	
	it 'can extract declarations' do
		subject.update(paths)
		
		expect(subject.definitions).to include(
			"Decode::Documentation",
			"Decode::Documentation#initialize",
			"Decode::Documentation#description",
			"Decode::Documentation#attributes",
			"Decode::Documentation#parameters",
		)
	end
	
	describe '#lookup' do
		it 'can lookup relative references' do
			subject.update(paths)
			
			initialize_reference = languages.reference_for('ruby', 'Decode::Documentation#initialize')
			initialize_definitions = subject.lookup(initialize_reference)
			expect(initialize_definitions.size).to be == 1
			
			source_reference = languages.reference_for('ruby', "Source")
			source_definitions = subject.lookup(source_reference, relative_to: initialize_definitions.first)
			expect(source_definitions.size).to be == 1
			expect(source_definitions.first.qualified_name).to be == "Decode::Source"
		end
	end
end
