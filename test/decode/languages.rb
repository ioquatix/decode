# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require 'decode/languages'

describe Decode::Languages do
	let(:languages) {subject.all}
	
	with '.reference' do
		with 'with language specific reference' do
			let(:reference) {languages.parse_reference("ruby Foo::Bar")}
			
			it 'can generate language specific references' do
				expect(reference).to be_a Decode::Language::Ruby::Reference
				
				expect(reference.identifier).to be == "Foo::Bar"
				expect(reference.language.name).to be == "ruby"
			end
		end
		
		with 'with generic reference' do
			let(:reference) {languages.parse_reference('generic Foo::Bar')}
			
			it 'can generate language specific references' do
				expect(reference).to be_a Decode::Language::Reference
				
				expect(reference.identifier).to be == "Foo::Bar"
				expect(reference.language.name).to be == "generic"
			end
		end
		
		with 'with default language' do
			let(:reference) {languages.parse_reference('Foo::Bar', default_language: Decode::Language::Ruby.new)}
			
			it 'can generate language specific references' do
				expect(reference).to be_a Decode::Language::Ruby::Reference
				
				expect(reference.identifier).to be == "Foo::Bar"
				expect(reference.language.name).to be == "ruby"
			end
		end
	end
end
