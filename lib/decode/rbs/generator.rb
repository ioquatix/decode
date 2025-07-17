# frozen_string_literal: true

require "rbs"
require_relative "../index"
require_relative "class"
require_relative "module"

module Decode
	module RBS
		class Generator
			def initialize
				# Set up RBS environment for type resolution
				@loader = ::RBS::EnvironmentLoader.new()
				@environment = ::RBS::Environment.from_loader(@loader).resolve_type_names
			end
			
			# Generate RBS declarations for the given index.
			# @parameter index [Decode::Index] The index containing definitions to generate RBS for.
			# @parameter output [IO] The output stream to write to.
			def generate(index, output: $stdout)
				# Build nested RBS AST structure using a hash for proper ||= behavior
				declarations = {}
				
				# Efficiently traverse the trie to find containers and their methods
				index.trie.traverse do |lexical_path, node, descend|
					# Process container definitions at this node
					if node.values
						containers = node.values.select {|definition| definition.container? && definition.public?}
						containers.each do |definition|
							case definition
							when Decode::Language::Ruby::Class, Decode::Language::Ruby::Module
								build_nested_declaration(definition, declarations, index)
							end
						end
					end
					
					# Continue traversing children
					descend.call
				end
				
				# Write the RBS output
				writer = ::RBS::Writer.new(out: output)
				
				unless declarations.empty?
					writer.write(declarations.values)
				end
			end
			
			private
			
			# Build nested RBS declarations preserving the parent hierarchy
			def build_nested_declaration(definition, declarations, index)
				# Create the declaration for this definition using ||= to avoid duplicates
				qualified_name = definition.qualified_name
				declarations[qualified_name] ||= definition_to_rbs(definition, index)
				
				# Add this declaration to its parent's members if it has a parent
				if definition.parent
					parent_qualified_name = definition.parent.qualified_name
					parent_container = declarations[parent_qualified_name]
					
					# Only add if not already present
					unless parent_container.members.any? {|member| 
						member.respond_to?(:name) && member.name.name == definition.name.to_sym 
					}
						parent_container.members << declarations[qualified_name]
					end
				end
			end
			
			# Convert a definition to RBS AST
			def definition_to_rbs(definition, index)
				case definition
				when Decode::Language::Ruby::Class
					Class.new(definition).to_rbs_ast(get_methods_for_definition(definition, index), index)
				when Decode::Language::Ruby::Module  
					Module.new(definition).to_rbs_ast(get_methods_for_definition(definition, index), index)
				end
			end
			
			# Get methods for a given definition efficiently using trie lookup
			def get_methods_for_definition(definition, index)
				# Use the trie to efficiently find methods for this definition
				if node = index.trie.lookup(definition.full_path)
					node.children.flat_map do |name, child|
						child.values.select {|symbol| symbol.is_a?(Decode::Language::Ruby::Method) && symbol.public?}
					end
				else
					[]
				end
			end
			
		end
	end
end 