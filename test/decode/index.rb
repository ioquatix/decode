# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020, by Samuel Williams.

require 'decode/index'
require 'build/files/glob'

describe Decode::Index do
	let(:index) {subject.new}
	let(:languages) {index.languages}
	let(:path) {File.expand_path("../../lib", __dir__)}
	let(:paths) {Build::Files::Glob.new(path, "**/*.rb")}
	
	it 'can extract declarations' do
		index.update(paths)
		
		expect(index.definitions).to be(:include?, "Decode::Documentation")
		expect(index.definitions).to be(:include?, "Decode::Documentation#initialize")
	end
	
	with '#lookup' do
		it 'can lookup relative references' do
			index.update(paths)
			
			initialize_reference = languages.reference_for('ruby', 'Decode::Documentation#initialize')
			initialize_definition = index.lookup(initialize_reference)
			expect(initialize_definition).not.to be_nil
			
			source_reference = languages.reference_for('ruby', "Source")
			source_definition = index.lookup(source_reference, relative_to: initialize_definition)
			expect(source_definition.qualified_name).to be == "Decode::Source"
		end
	end
end
