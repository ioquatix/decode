# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

def initialize(...)
	super
	
	require "decode/index"
	require "rbs"
	require "types"
	
	# Set up RBS environment for type resolution
	@rbs_loader = RBS::EnvironmentLoader.new()
	@rbs_environment = RBS::Environment.from_loader(@rbs_loader).resolve_type_names
end

# Generate RBS declarations for the given source root.
# @parameter root [String] The root path to index.
def generate(root)
	# Handle both files and directories
	paths = if File.directory?(root)
		Dir.glob(File.join(root, "**/*"))
	elsif File.file?(root)
		[root]
	else
		# Handle glob patterns or non-existent paths
		Dir.glob(root)
	end
	
	index = Decode::Index.new
	index.update(paths)
	
	# Build nested RBS AST structure using a hash for proper ||= behavior
	declarations = {}
	
	# Collect all definitions
	index.definitions.each do |qualified_name, definition|
		if definition.public?
			case definition
			when Decode::Language::Ruby::Class, Decode::Language::Ruby::Module
				build_nested_declaration(definition, declarations, index)
			end
		end
	end
	
	# Convert the nested structure to declarations array - only root-level declarations
	# Find the shortest qualified name path (the root namespace)
	shortest_path_length = declarations.keys.map {|key| key.split("::").length}.min
	root_declarations = declarations.select {|qualified_name, decl| 
		qualified_name.split("::").length == shortest_path_length
	}.values.compact
	declarations = root_declarations
	
	# Write the RBS output
	writer = RBS::Writer.new(out: $stdout)
	
	unless declarations.empty?
		writer.write(declarations)
	end
end

private

def definition_to_rbs(definition, index)
	case definition
	when Decode::Language::Ruby::Class
		class_to_rbs(definition, get_methods_for_definition(definition, index), index)
	when Decode::Language::Ruby::Module  
		module_to_rbs(definition, get_methods_for_definition(definition, index), index)
	end
end

# Build nested RBS declarations preserving the parent hierarchy
def build_nested_declaration(definition, declarations, index)
	# Ensure all parent containers exist using ||= for proper reuse
	ensure_parent_containers_exist(definition, declarations, index)
	
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

# Ensure all parent containers exist using ||= for proper reuse
def ensure_parent_containers_exist(definition, declarations, index)
	current = definition.parent
	
	while current
		qualified_name = current.qualified_name
		
		# Use ||= to create parent container only if it doesn't exist
		declarations[qualified_name] ||= create_parent_container(current)
		
		current = current.parent
	end
end

# Create a parent container (module) for a definition
def create_parent_container(definition)
	name = simple_name_to_rbs(definition.name)
	comment = extract_comment(definition)
	
	case definition
	when Decode::Language::Ruby::Class
		RBS::AST::Declarations::Class.new(
			name: name,
			type_params: [],
			super_class: nil,
			members: [],
			annotations: [],
			location: nil,
			comment: comment
		)
	else
		RBS::AST::Declarations::Module.new(
			name: name,
			type_params: [],
			self_types: [],
			members: [],
			annotations: [],
			location: nil,
			comment: comment
		)
	end
end

# Get methods for a given definition
def get_methods_for_definition(definition, index)
	methods = []
	
	# Look for methods that are children of this definition
	index.definitions.each do |qualified_name, child_def|
		if child_def.is_a?(Decode::Language::Ruby::Method) && child_def.parent == definition && child_def.public?
			methods << child_def
		end
	end
	
	methods
end

# Convert a simple name to RBS TypeName (not qualified)
def simple_name_to_rbs(name)
	RBS::TypeName.new(name: name.to_sym, namespace: RBS::Namespace.empty)
end

# Convert a class definition to RBS.
def class_to_rbs(definition, method_definitions = [], index = nil)
	name = simple_name_to_rbs(definition.name)
	comment = extract_comment(definition)
	
	# Build method definitions
	methods = method_definitions.map {|method_def| method_to_rbs(method_def, index)}.compact
	
	# For now, just create a simple class declaration
	RBS::AST::Declarations::Class.new(
		name: name,
		type_params: [],
		super_class: nil,
		members: methods,
		annotations: [],
		location: nil,
		comment: comment
	)
end

# Convert a module definition to RBS.
def module_to_rbs(definition, method_definitions = [], index = nil)
	name = simple_name_to_rbs(definition.name)
	comment = extract_comment(definition)
	
	# Build method definitions
	methods = method_definitions.map {|method_def| method_to_rbs(method_def, index)}.compact
	
	RBS::AST::Declarations::Module.new(
		name: name,
		type_params: [],
		self_types: [],
		members: methods,
		annotations: [],
		location: nil,
		comment: comment
	)
end

# Convert a method definition to RBS.
def method_to_rbs(definition, index)
	method_name = definition.name
	
	# Extract type information from documentation
	return_type = extract_return_type(definition, index)
	parameters = extract_parameters(definition, index)
	comment = extract_comment(definition)
	
	# Extract block information from documentation
	block_type = extract_block_type(definition, index)
	
	# Create a method type with extracted type information
	method_type = RBS::MethodType.new(
		type_params: [],
		type: RBS::Types::Function.new(
			required_positionals: parameters,
			optional_positionals: [],
			rest_positionals: nil,
			trailing_positionals: [],
			required_keywords: {},
			optional_keywords: {},
			rest_keywords: nil,
			return_type: return_type
		),
		block: block_type,
		location: nil
	)
	
	# Determine method kind (instance vs singleton)
	kind = if definition.receiver
		:singleton
	else
		:instance
	end
	
	RBS::AST::Members::MethodDefinition.new(
		name: method_name.to_sym,
		kind: kind,
		overloads: [
			RBS::AST::Members::MethodDefinition::Overload.new(
				method_type: method_type,
				annotations: []
			)
		],
		annotations: [],
		location: nil,
		comment: comment,
		overloading: false,
		visibility: :public
	)
end

# Extract return type from method documentation.
def extract_return_type(definition, index)
	# Look for @returns tags in the method's documentation
	documentation = definition.documentation
	
	# Find @returns tag
	returns_tag = documentation&.filter(Decode::Comment::Returns)&.first
	
	if returns_tag
		# Parse the type from the tag
		type_string = returns_tag.type.strip
		parse_type_string(type_string)
	else
		# Infer return type based on method name patterns
		infer_return_type(definition)
	end
end

# Extract parameter types from method documentation.
def extract_parameters(definition, index)
	documentation = definition.documentation
	return [] unless documentation
	
	# Find @parameter tags
	param_tags = documentation.filter(Decode::Comment::Parameter).to_a
	return [] if param_tags.empty?
	
	param_tags.map do |tag|
		name = tag.name
		type_string = tag.type.strip
		type = parse_type_string(type_string)
		
		RBS::Types::Function::Param.new(
			type: type,
			name: name.to_sym
		)
	end
end

# Extract block type from method documentation.
def extract_block_type(definition, index)
	documentation = definition.documentation
	return nil unless documentation
	
	# Find @yields tags
	yields_tag = documentation.filter(Decode::Comment::Yields).first
	return nil unless yields_tag
	
	# Extract block parameters from nested @parameter tags
	block_params = yields_tag.filter(Decode::Comment::Parameter).map do |param_tag|
		name = param_tag.name
		type_string = param_tag.type.strip
		type = parse_type_string(type_string)
		
		RBS::Types::Function::Param.new(
			type: type,
			name: name.to_sym
		)
	end
	
	# Parse the block signature to determine if it's required
	# Check both the directive name and the block signature
	block_signature = yields_tag.block
	directive_name = yields_tag.directive
	required = !directive_name.include?("?") && !block_signature.include?("?") && !block_signature.include?("optional")
	
	# Determine block return type (default to void if not specified)
	block_return_type = RBS::Parser.parse_type("void")
	
	# Create the block function type
	block_function = RBS::Types::Function.new(
		required_positionals: block_params,
		optional_positionals: [],
		rest_positionals: nil,
		trailing_positionals: [],
		required_keywords: {},
		optional_keywords: {},
		rest_keywords: nil,
		return_type: block_return_type
	)
	
	# Create and return the block type
	RBS::Types::Block.new(
		type: block_function,
		required: required,
		self_type: nil
	)
end

# Infer return type based on method patterns and heuristics.
def infer_return_type(definition)
	method_name = definition.name
	method_name_str = method_name.to_s
	
	# Methods ending with ? are typically boolean
	if method_name_str.end_with?("?")
		return RBS::Parser.parse_type("bool")
	end
	
	# Methods named initialize return void
	if method_name == :initialize
		return RBS::Parser.parse_type("void")
	end
	
	# Methods with names that suggest they return self
	if method_name_str.match?(/^(add|append|prepend|push|<<|concat|merge!|sort!|reverse!|clear|delete|remove)/)
		return RBS::Parser.parse_type("self")
	end
	
	# Default to untyped
	RBS::Parser.parse_type("untyped")
end

# Extract comment from method documentation.
def extract_comment(definition)
	documentation = definition.documentation
	return nil unless documentation
	
	# Extract the main description text (non-tag content)
	comment_lines = []
	
	documentation.children&.each do |child|
		if child.is_a?(Decode::Comment::Text)
			comment_lines << child.line.strip
		elsif !child.is_a?(Decode::Comment::Tag)
			# Handle other text-like nodes
			comment_lines << child.to_s.strip if child.respond_to?(:to_s)
		end
	end
	
	# Join lines with newlines to preserve markdown formatting
	unless comment_lines.empty?
		comment_text = comment_lines.join("\n").strip
		return RBS::AST::Comment.new(string: comment_text, location: nil) unless comment_text.empty?
	end
	
	nil
end

# Parse a type string and convert it to RBS type using RBS's built-in parser and environment.
def parse_type_string(type_string)
	type = Types.parse(type_string)
	return RBS::Parser.parse_type(type.to_rbs)
rescue => error
	Console.warn(self, "Failed to parse type string: #{type_string}", error)
	return RBS::Parser.parse_type("untyped")
end

# Convert a qualified name to RBS TypeName.
def qualified_name_to_rbs(qualified_name)
	parts = qualified_name.split("::")
	name = parts.pop
	namespace = RBS::Namespace.new(path: parts.map(&:to_sym), absolute: true)
	
	RBS::TypeName.new(name: name.to_sym, namespace: namespace)
end
