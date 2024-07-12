# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

require 'decode/source'
require 'decode/language/ruby'

describe Decode::Language::Ruby do
	let(:path) {File.expand_path(".fixtures/ruby.rb", __dir__)}
	let(:language) {subject.new}
	let(:source) {Decode::Source.new(path, language)}
	let(:definitions) {source.definitions.to_a}
	let(:segments) {source.segments.to_a}
	
	with 'classes' do
		let(:path) {File.expand_path(".fixtures/classes.rb", __dir__)}
		
		it 'can extract definitions' do
			expect(definitions).not.to be(:empty?)
		end
		
		it 'has a location' do
			location = definitions.first.location
			expect(location).not.to be_nil
			expect(location.path).to be == path
			expect(location.line).to be == 6
			expect(location.to_s).to be == "#{path}:6"
		end
		
		it 'has short form' do
			expect(definitions[0].short_form).to be == 'class Parent'
			expect(definitions[1].short_form).to be == 'class Child'
			expect(definitions[2].short_form).to be == 'class << self'
			expect(definitions[3].short_form).to be == 'class Child'
		end
		
		it 'has long form' do
			expect(definitions[0].long_form).to be == 'class Parent'
			expect(definitions[1].long_form).to be == 'class Child < Parent'
			expect(definitions[2].long_form).to be == 'class << self'
			expect(definitions[3].long_form).to be == 'class My::Nested::Child'
		end
	end
	
	with 'modules' do
		let(:path) {File.expand_path(".fixtures/modules.rb", __dir__)}
		
		it 'can extract definitions' do
			expect(definitions).not.to be(:empty?)
		end
		
		it 'has short form' do
			expect(definitions[0].short_form).to be == 'module X'
			expect(definitions[1].short_form).to be == 'module Y'
		end
		
		it 'has long form' do
			expect(definitions[0].long_form).to be == 'module X'
			expect(definitions[1].long_form).to be == 'module X::Y'
		end
		
		it 'has fully qualified form' do
			expect(definitions[0].qualified_form).to be == 'module X'
			expect(definitions[1].qualified_form).to be == 'module X::Y'
		end
	end
	
	with 'nested modules' do
		let(:path) {File.expand_path(".fixtures/nested_modules.rb", __dir__)}
		
		it 'can extract definitions' do
			expect(definitions).not.to be(:empty?)
		end
		
		it 'has short form' do
			expect(definitions[0].short_form).to be == 'module Y'
			expect(definitions[1].short_form).to be == 'module Z'
		end
		
		it 'has full path' do
			expect(definitions[1].path).to be == [:X, :Y, :Z]
		end
		
		it 'has long form' do
			expect(definitions[0].long_form).to be == 'module X::Y'
			expect(definitions[1].long_form).to be == 'module X::Y::Z'
		end
		
		it 'has fully qualified form' do
			expect(definitions[0].qualified_form).to be == 'module X::Y'
			expect(definitions[1].qualified_form).to be == 'module X::Y::Z'
		end
	end
	
	with 'instance methods' do
		let(:path) {File.expand_path(".fixtures/instance_methods.rb", __dir__)}
		
		it 'can extract definitions' do
			expect(definitions).not.to be(:empty?)
		end
		
		it 'has short form' do
			expect(definitions[0].short_form).to be == 'def without_arguments'
			expect(definitions[1].short_form).to be == 'def with_arguments'
		end
		
		it 'has long form' do
			expect(definitions[0].long_form).to be == 'def without_arguments'
			expect(definitions[1].long_form).to be == 'def with_arguments(x = 10)'
		end
	end
	
	with 'class methods' do
		let(:path) {File.expand_path(".fixtures/class_methods.rb", __dir__)}
		
		it 'can extract definitions' do
			expect(definitions).not.to be(:empty?)
		end
		
		it 'has short form' do
			expect(definitions[0].short_form).to be == 'def self.without_arguments'
			expect(definitions[1].short_form).to be == 'def self.with_arguments'
		end
		
		it 'has long form' do
			expect(definitions[0].long_form).to be == 'def self.without_arguments'
			expect(definitions[1].long_form).to be == 'def self.with_arguments(x = 10)'
		end
	end
	
	with 'functions' do
		let(:path) {File.expand_path(".fixtures/functions.rb", __dir__)}
		
		it 'can extract definitions' do
			expect(definitions).not.to be(:empty?)
		end
		
		it 'has short form' do
			expect(definitions[1].short_form).to be == 'def Foo.bar'
		end
		
		it 'has long form' do
			expect(definitions[1].long_form).to be == 'def Foo.bar(...)'
		end
		
		it 'has correct path' do
			expect(definitions[1].path).to be == [:Foo, :bar]
		end
	end
	
	with 'constants' do
		let(:path) {File.expand_path(".fixtures/constants.rb", __dir__)}
		
		it 'can extract definitions' do
			expect(definitions).not.to be(:empty?)
		end
		
		it 'has short form' do
			expect(definitions[0].short_form).to be == 'SINGLE_LINE_STRING'
			expect(definitions[1].short_form).to be == 'MULTI_LINE_ARRAY'
			expect(definitions[2].short_form).to be == 'MULTI_LINE_HASH'
		end
		
		it 'has long form' do
			expect(definitions[0].long_form).to be == 'SINGLE_LINE_STRING = "Hello World"'
			expect(definitions[1].long_form).to be == 'MULTI_LINE_ARRAY = [...]'
			expect(definitions[2].long_form).to be == 'MULTI_LINE_HASH = {...}'
		end
	end
	
	with 'attributes' do
		let(:path) {File.expand_path(".fixtures/attributes.rb", __dir__)}
		
		it 'can extract definitions' do
			expect(definitions).not.to be(:empty?)
		end
		
		it 'has short form' do
			expect(definitions[0].short_form).to be == 'attr :a'
			expect(definitions[1].short_form).to be == 'attr_reader :b'
			expect(definitions[2].short_form).to be == 'attr_writer :c'
			expect(definitions[3].short_form).to be == 'attr_accessor :d'
		end
		
		it 'has long form' do
			expect(definitions[0].long_form).to be == 'attr :a'
			expect(definitions[1].long_form).to be == 'attr_reader :b'
			expect(definitions[2].long_form).to be == 'attr_writer :c'
			expect(definitions[3].long_form).to be == 'attr_accessor :d'
		end
	end
	
	with 'comments' do
		let(:path) {File.expand_path(".fixtures/comments.rb", __dir__)}
		
		it 'can extract definitions' do
			expect(definitions).not.to be(:empty?)
		end
		
		it 'can extract segments' do
			expect(segments).not.to be(:empty?)
			expect(segments.size).to be == 2
		end
		
		it 'can extract comments' do
			expect(segments[0].comments).to be == ["Firstly, we define a method:"]
			expect(segments[1].comments).to be == ["Then we invoke it:"]
		end
		
		it 'can extract code' do
			expect(segments[0].code).to be == "def method\n\t# Frobulate the combobulator:\n\t$combobulator.frobulate\nend"
			expect(segments[1].code).to be == "result = self.method\nputs result"
		end
	end
	
	with 'block' do
		let(:path) {File.expand_path(".fixtures/block.rb", __dir__)}
		
		it 'can extract definitions' do
			expect(definitions).not.to be(:empty?)
		end
		
		it 'defines scope' do
			expect(definitions[0].name).to be == :Foo
			expect(definitions[1].name).to be == :Bar
		end
		
		it 'has short form' do
			expect(definitions[2].short_form).to be == "local"
			expect(definitions[3].short_form).to be == "hostname"
			expect(definitions[4].short_form).to be == "context { ... }"
		end
		
		it 'has long form' do
			expect(definitions[2].long_form).to be == "add(:local)"
			expect(definitions[3].long_form).to be == "hostname \"localhost\""
			expect(definitions[4].long_form).to be == "context {Context.new(hostname)}"
		end
		
		it 'has text' do
			expect(definitions[2].text).to be == <<~TEXT.chomp
			add(:local) do
				# The default hostname for the connection.
				# @name hostname
				# @attribute [String]
				hostname "localhost"
				
				# The default context for managing the connection.
				# @attribute [Context]
				context {Context.new(hostname)}
			end
			TEXT
		end
		
		it 'has correct nesting' do
			expect(definitions[2]).to be(:container?)
			expect(definitions[4]).not.to be(:container?)
		end
	end
	
	with 'private' do
		let(:path) {File.expand_path(".fixtures/private.rb", __dir__)}
		
		it 'can extract definitions' do
			expect(definitions).not.to be(:empty?)
		end
		
		it 'has public and private methods' do
			expect(definitions.size).to be == 7
			expect(definitions[0].visibility).to be == :public
			expect(definitions[1].visibility).to be == :public
			expect(definitions[2].visibility).to be == :public
			expect(definitions[3].visibility).to be == :private
			expect(definitions[4].visibility).to be == :private
			expect(definitions[5].visibility).to be == :public
			expect(definitions[6].visibility).to be == :public
		end
	end
end
