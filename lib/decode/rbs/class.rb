# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "rbs"
require_relative "wrapper"
require_relative "method"
module Decode
	module RBS
		class Class < Wrapper
			
			def initialize(definition)
				super
				@generics = nil
			end
			
			def generics
				@generics ||= extract_generics
			end
			
			# Convert the class definition to RBS AST
			def to_rbs_ast(method_definitions = [], index = nil)
				name = simple_name_to_rbs(@definition.name)
				comment = extract_comment(@definition)
				
				# Extract generics from RBS tags
				type_params = generics.map do |generic|
					::RBS::AST::TypeParam.new(
						name: generic.to_sym,
						variance: nil,
						upper_bound: nil,
						location: nil
					)
				end
				
				# Build method definitions
				methods = method_definitions.map{|method_def| Method.new(method_def).to_rbs_ast(index)}.compact
				
				# Extract super class if present
				super_class = if @definition.super_class
					::RBS::AST::Declarations::Class::Super.new(
						name: qualified_name_to_rbs(@definition.super_class),
						args: [],
						location: nil
					)
				end
				
				# Create the class declaration with generics
				::RBS::AST::Declarations::Class.new(
					name: name,
					type_params: type_params,
					super_class: super_class,
					members: methods,
					annotations: [],
					location: nil,
					comment: comment
				)
			end
			
			private
			
			def extract_generics
				tags.select(&:generic?).map(&:generic_parameter)
			end
			
			# Convert a simple name to RBS TypeName (not qualified)
			def simple_name_to_rbs(name)
				::RBS::TypeName.new(name: name.to_sym, namespace: ::RBS::Namespace.empty)
			end
			
			# Convert a qualified name to RBS TypeName
			def qualified_name_to_rbs(qualified_name)
				parts = qualified_name.split("::")
				name = parts.pop
				namespace = ::RBS::Namespace.new(path: parts.map(&:to_sym), absolute: true)
				
				::RBS::TypeName.new(name: name.to_sym, namespace: namespace)
			end
			
		end
	end
end
