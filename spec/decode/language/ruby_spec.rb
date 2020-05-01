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

RSpec.describe Decode::Language::Ruby do
	let(:path) {File.expand_path("fixtures/ruby.rb", __dir__)}
	let(:source) {Decode::Source.new(path)}
	let(:declarations) {source.parse.to_a}
	
	context 'with classes' do
		let(:path) {File.expand_path("fixtures/classes.rb", __dir__)}
		
		it 'can extract declarations' do
			expect(declarations).to_not be_empty
		end
		
		it 'has short form' do
			expect(declarations[0].short_form).to be == 'class Parent'
			expect(declarations[1].short_form).to be == 'class Child'
			expect(declarations[2].short_form).to be == 'class << (self)'
		end
		
		it 'has long form' do
			expect(declarations[0].long_form).to be == 'class Parent'
			expect(declarations[1].long_form).to be == 'class Child < Parent'
			expect(declarations[2].long_form).to be == 'class << (self)'
		end
	end
	
	context 'with instance methods' do
		let(:path) {File.expand_path("fixtures/instance_methods.rb", __dir__)}
		
		it 'can extract declarations' do
			expect(declarations).to_not be_empty
		end
		
		it 'has short form' do
			expect(declarations[0].short_form).to be == 'def without_arguments'
			expect(declarations[1].short_form).to be == 'def with_arguments'
		end
		
		it 'has long form' do
			expect(declarations[0].long_form).to be == 'def without_arguments'
			expect(declarations[1].long_form).to be == 'def with_arguments(x = 10)'
		end
	end
	
	context 'with class methods' do
		let(:path) {File.expand_path("fixtures/class_methods.rb", __dir__)}
		
		it 'can extract declarations' do
			expect(declarations).to_not be_empty
		end
		
		it 'has short form' do
			expect(declarations[0].short_form).to be == 'def self.without_arguments'
			expect(declarations[1].short_form).to be == 'def self.with_arguments'
		end
		
		it 'has long form' do
			expect(declarations[0].long_form).to be == 'def self.without_arguments'
			expect(declarations[1].long_form).to be == 'def self.with_arguments(x = 10)'
		end
	end
	
	context 'with constants' do
		let(:path) {File.expand_path("fixtures/constants.rb", __dir__)}
		
		it 'can extract declarations' do
			expect(declarations).to_not be_empty
		end
		
		it 'has short form' do
			expect(declarations[0].short_form).to be == 'SINGLE_LINE_STRING'
			expect(declarations[1].short_form).to be == 'MULTI_LINE_ARRAY'
			expect(declarations[2].short_form).to be == 'MULTI_LINE_HASH'
		end
		
		it 'has long form' do
			expect(declarations[0].long_form).to be == 'SINGLE_LINE_STRING = "Hello World"'
			expect(declarations[1].long_form).to be == 'MULTI_LINE_ARRAY = [...]'
			expect(declarations[2].long_form).to be == 'MULTI_LINE_HASH = {...}'
		end
	end
end
