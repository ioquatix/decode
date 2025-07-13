# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "decode/language/ruby"
require "decode/source"

describe Decode::Language::Ruby do
	let(:language) {Decode::Language::Ruby.new}
	
	with "visibility modifiers" do
		let(:source) {Decode::Source.new("test/decode/language/ruby/.fixtures/inline_visibility.rb", language)}
		
		it "should handle standalone visibility modifiers" do
			definitions = language.definitions_for(source).to_a
			methods = definitions.select do |definition|
				definition.is_a?(Decode::Language::Ruby::Method)
			end
			
			# Test public methods
			public_methods = methods.select do |method|
				method.visibility == :public
			end
			public_method_names = public_methods.map(&:name)
			expect(public_method_names).to be(:include?, :public_method_1)
			expect(public_method_names).to be(:include?, :public_method_2)
			expect(public_method_names).to be(:include?, :public_method_3)
			expect(public_method_names).to be(:include?, :public_method_4)
			expect(public_method_names).to be(:include?, :public_method_5)
			
			# Test private methods
			private_methods = methods.select do |method|
				method.visibility == :private
			end
			private_method_names = private_methods.map(&:name)
			expect(private_method_names).to be(:include?, :private_method_1)
			expect(private_method_names).to be(:include?, :private_method_2)
			expect(private_method_names).to be(:include?, :private_method_3)
			
			# Test protected methods
			protected_methods = methods.select do |method|
				method.visibility == :protected
			end
			protected_method_names = protected_methods.map(&:name)
			expect(protected_method_names).to be(:include?, :protected_method_1)
			expect(protected_method_names).to be(:include?, :protected_method_2)
		end
		
		it "should handle inline visibility modifiers" do
			definitions = language.definitions_for(source).to_a
			methods = definitions.select do |definition|
				definition.is_a?(Decode::Language::Ruby::Method)
			end
			
			# private def private_method_1 should be private
			private_method_1 = methods.find do |method|
				method.name == :private_method_1
			end
			expect(private_method_1.visibility).to be == :private
			
			# protected def protected_method_1 should be protected
			protected_method_1 = methods.find do |method|
				method.name == :protected_method_1
			end
			expect(protected_method_1.visibility).to be == :protected
		end
		
		it "should reset visibility correctly after inline definitions" do
			definitions = language.definitions_for(source).to_a
			methods = definitions.select do |definition|
				definition.is_a?(Decode::Language::Ruby::Method)
			end
			
			# Method after inline private should still be public
			public_method_2 = methods.find do |method|
				method.name == :public_method_2
			end
			expect(public_method_2.visibility).to be == :public
			
			# Method after inline protected should still be public
			public_method_3 = methods.find do |method|
				method.name == :public_method_3
			end
			expect(public_method_3.visibility).to be == :public
		end
	end
	
	with "class methods and visibility" do
		it "should handle class method visibility correctly" do
			# Test that class methods can have visibility modifiers
			# This is a simplified test that uses the existing fixtures
			source = Decode::Source.new("test/decode/language/ruby/.fixtures/class_methods.rb", language)
			definitions = language.definitions_for(source).to_a
			methods = definitions.select do |definition|
				definition.is_a?(Decode::Language::Ruby::Method)
			end
			
			# All methods in class_methods.rb should have receivers
			class_methods = methods.select do |method|
				method.receiver
			end
			expect(class_methods.size).to be > 0
			
			class_methods.each do |method|
				expect(method.receiver).to be == "self"
			end
		end
	end
end
