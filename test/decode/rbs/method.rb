# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "decode/language/ruby"
require "decode/rbs/method"
require "decode/definition"
require "decode/documentation"
require "decode/comment/rbs"
require "decode/comment/text"
require "decode/comment/returns"
require "decode/comment/parameter"
require "decode/comment/yields"

describe Decode::RBS::Method do
	let(:language) {Decode::Language::Ruby.new}
	let(:comments) {[]}
	let(:definition) {Decode::Language::Ruby::Method.new([:test_method], comments: comments, language: language)}
	let(:rbs_method) {subject.new(definition)}
	
	with "#initialize" do
		it "initializes with definition and sets up instance variables" do
			expect(rbs_method.instance_variable_get(:@definition)).to be == definition
			expect(rbs_method.instance_variable_get(:@signatures)).to be_nil
		end
		
		it "inherits from Wrapper" do
			expect(rbs_method).to be_a(Decode::RBS::Wrapper)
		end
	end
	
	with "#signatures" do
		with "no RBS tags" do
			it "returns empty array when no method signature tags found" do
				expect(rbs_method.signatures).to be == []
			end
		end
		
		with "RBS tags with method signatures" do
			let(:comments) {["@rbs (String) -> Integer"]}
			
			it "extracts method signatures from RBS tags" do
				expect(rbs_method.signatures).to be == ["(String) -> Integer"]
			end
		end
		
		with "multiple method signatures" do
			let(:comments) {["@rbs (String) -> Integer", "@rbs (Integer) -> String"]}
			
			it "extracts multiple method signatures" do
				expect(rbs_method.signatures).to be == ["(String) -> Integer", "(Integer) -> String"]
			end
		end
	end
	
	with "#to_rbs_ast" do
		with "method with explicit signatures" do
			let(:comments) {["@rbs (String) -> Integer"]}
			
			it "generates RBS AST with explicit signatures" do
				ast = rbs_method.to_rbs_ast
				
				expect(ast).to be_a(::RBS::AST::Members::MethodDefinition)
				expect(ast.name).to be == :test_method
				expect(ast.overloads).to have_attributes(length: be == 1)
			end
		end
		
		with "method without explicit signatures" do
			it "generates RBS AST with inferred types" do
				ast = rbs_method.to_rbs_ast
				
				expect(ast).to be_a(::RBS::AST::Members::MethodDefinition)
				expect(ast.name).to be == :test_method
				expect(ast.overloads).to have_attributes(length: be == 1)
			end
		end
		
		with "method with documentation" do
			let(:comments) {["This is a test method"]}
			
			it "includes comment in RBS AST" do
				ast = rbs_method.to_rbs_ast
				
				expect(ast.comment).not.to be_nil
				expect(ast.comment.string).to be == "This is a test method"
			end
		end
	end
	
	with "private methods" do
		with "#infer_return_type" do
			with "boolean method" do
				let(:bool_definition) {Decode::Language::Ruby::Method.new([:empty?], comments: comments, language: language)}
				let(:bool_method) {subject.new(bool_definition)}
				
				it "infers boolean return type for methods ending with ?" do
					return_type = bool_method.send(:infer_return_type, bool_definition)
					expect(return_type.to_s).to be == "bool"
				end
			end
			
			with "initialize method" do
				let(:init_definition) {Decode::Language::Ruby::Method.new([:initialize], comments: comments, language: language)}
				let(:init_method) {subject.new(init_definition)}
				
				it "infers void return type for initialize method" do
					return_type = init_method.send(:infer_return_type, init_definition)
					expect(return_type.to_s).to be == "void"
				end
			end
			
			with "self-returning method" do
				let(:append_definition) {Decode::Language::Ruby::Method.new([:append], comments: comments, language: language)}
				let(:append_method) {subject.new(append_definition)}
				
				it "infers self return type for mutating methods" do
					return_type = append_method.send(:infer_return_type, append_definition)
					expect(return_type.to_s).to be == "self"
				end
			end
			
			with "default method" do
				it "infers untyped return type for default methods" do
					return_type = rbs_method.send(:infer_return_type, definition)
					expect(return_type.to_s).to be == "untyped"
				end
			end
		end
		
		with "#extract_return_type" do
			with "method with @returns tag" do
				let(:comments) {["@returns String"]}
				
				it "extracts return type from @returns tag" do
					return_type = rbs_method.send(:extract_return_type, definition, nil)
					expect(return_type).not.to be_nil
					# The exact type depends on the Types.parse implementation
				end
			end
			
			with "method without @returns tag" do
				it "falls back to inferred return type" do
					return_type = rbs_method.send(:extract_return_type, definition, nil)
					expect(return_type.to_s).to be == "untyped"
				end
			end
		end
		
		with "#extract_parameters" do
			with "method with @parameter tags" do
				let(:comments) {["@parameter name [String] The name parameter"]}
				
				it "extracts parameters from @parameter tags" do
					parameters = rbs_method.send(:extract_parameters, definition, nil)
					expect(parameters).to have_attributes(length: be == 1)
					expect(parameters.first.name).to be == :name
				end
			end
			
			with "method without @parameter tags" do
				it "returns empty array when no parameter tags" do
					parameters = rbs_method.send(:extract_parameters, definition, nil)
					expect(parameters).to be == []
				end
			end
		end
		
		with "#extract_block_type" do
			with "method with @yields tag" do
				let(:comments) {["@yields {|item| ...} Each item in the collection"]}
				
				it "extracts block type from @yields tag" do
					block_type = rbs_method.send(:extract_block_type, definition, nil)
					expect(block_type).to be_a(::RBS::Types::Block)
					expect(block_type.required).to be_truthy
				end
			end
			
			with "method without @yields tag" do
				it "returns nil when no yields tag" do
					block_type = rbs_method.send(:extract_block_type, definition, nil)
					expect(block_type).to be_nil
				end
			end
		end
		
		with "#parse_type_string" do
			it "parses valid type strings" do
				type = rbs_method.send(:parse_type_string, "String")
				expect(type).not.to be_nil
			end
		end
		
		with "#extract_comment" do
			with "method with text documentation" do
				let(:comments) {["Test method comment"]}
				
				it "extracts comment from documentation" do
					comment = rbs_method.send(:extract_comment, definition)
					
					expect(comment).to be_a(::RBS::AST::Comment)
					expect(comment.string).to be == "Test method comment"
				end
			end
			
			with "method without documentation" do
				it "returns nil when no documentation" do
					comment = rbs_method.send(:extract_comment, definition)
					expect(comment).to be_nil
				end
			end
		end
	end
end
