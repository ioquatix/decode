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

require 'decode/languages'

RSpec.describe Decode::Languages do
	subject(:languages) {described_class.all}
	
	describe '.reference' do
		context 'with language specific reference' do
			subject(:reference) {languages.parse_reference("ruby Foo::Bar")}
			
			it 'can generate language specific references' do
				expect(reference).to be_kind_of Decode::Language::Ruby::Reference
				
				expect(reference.identifier).to be == "Foo::Bar"
				expect(reference.language.name).to be == "ruby"
			end
		end
		
		context 'with generic reference' do
			subject(:reference) {languages.parse_reference('generic Foo::Bar')}
			
			it 'can generate language specific references' do
				expect(reference).to be_kind_of Decode::Language::Reference
				
				expect(reference.identifier).to be == "Foo::Bar"
				expect(reference.language.name).to be == "generic"
			end
		end
		
		context 'with default language' do
			subject(:reference) {languages.parse_reference('Foo::Bar', default_language: Decode::Language::Ruby.new)}
			
			it 'can generate language specific references' do
				expect(reference).to be_kind_of Decode::Language::Ruby::Reference
				
				expect(reference.identifier).to be == "Foo::Bar"
				expect(reference.language.name).to be == "ruby"
			end
		end
	end
end
