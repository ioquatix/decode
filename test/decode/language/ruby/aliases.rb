# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "decode/language/ruby"
require "decode/source"

describe Decode::Language::Ruby do
	let(:language) {Decode::Language::Ruby.new}
	
	with "alias definitions" do
		let(:source) {Decode::Source.new("test/decode/language/ruby/.fixtures/aliases.rb", language)}
		
		it "should extract alias definitions" do
			definitions = language.definitions_for(source).to_a
			
			aliases = definitions.select do |definition|
				definition.is_a?(Decode::Language::Ruby::Alias)
			end
			expect(aliases.size).to be == 4
			
			# Check regular alias
			new_method_alias = aliases.find do |alias_definition|
				alias_definition.name == :new_method
			end
			expect(new_method_alias).to be_a(Decode::Language::Ruby::Alias)
			expect(new_method_alias.old_name).to be == :original_method
			expect(new_method_alias.visibility).to be == :public
			
			# Check alias_method
			another_method_alias = aliases.find do |alias_definition|
				alias_definition.name == :another_method
			end
			expect(another_method_alias).to be_a(Decode::Language::Ruby::Alias)
			expect(another_method_alias.old_name).to be == :original_method
			expect(another_method_alias.visibility).to be == :public
			
			# Check private aliases
			private_alias = aliases.find do |alias_definition|
				alias_definition.name == :private_alias
			end
			expect(private_alias).to be_a(Decode::Language::Ruby::Alias)
			expect(private_alias.old_name).to be == :private_original
			expect(private_alias.visibility).to be == :private
			
			private_alias_method = aliases.find do |alias_definition|
				alias_definition.name == :private_alias_method
			end
			expect(private_alias_method).to be_a(Decode::Language::Ruby::Alias)
			expect(private_alias_method.old_name).to be == :private_original
			expect(private_alias_method.visibility).to be == :private
		end
		
		it "should have correct short and long forms" do
			definitions = language.definitions_for(source).to_a
			alias_def = definitions.find do |definition|
				definition.is_a?(Decode::Language::Ruby::Alias) && definition.name == :new_method
			end
			
			expect(alias_def.short_form).to be == "alias new_method original_method"
			expect(alias_def.long_form).to be == "alias new_method original_method"
		end
	end
end
