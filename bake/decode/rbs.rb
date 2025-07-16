# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

def initialize(...)
	super
	
	require "decode/index"
	require "rbs"
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
	
	# Group definitions by qualified name to avoid duplicates
	class_defs = {}
	module_defs = {}
	methods = {}
	
	# Collect all definitions
	index.trie.traverse do |path, node, descend|
		node.values&.each do |definition|
			if definition.public?
				case definition
				when Decode::Language::Ruby::Class
					class_defs[definition.qualified_name] = definition
				when Decode::Language::Ruby::Module
					module_defs[definition.qualified_name] = definition
				when Decode::Language::Ruby::Method
					parent_name = definition.parent&.qualified_name
					if parent_name
						methods[parent_name] ||= []
						methods[parent_name] << definition
					end
				end
			end
		end
		
		descend.call
	end
	
	declarations = []
	
	# Generate class declarations with methods
	class_defs.each do |name, definition|
		declaration = class_to_rbs(definition, methods[name] || [], index)
		declarations << declaration if declaration
	end
	
	# Generate module declarations with methods
	module_defs.each do |name, definition|
		declaration = module_to_rbs(definition, methods[name] || [], index)
		declarations << declaration if declaration
	end
	
	# Write the RBS output
	io = StringIO.new
	writer = RBS::Writer.new(out: io)
	
	unless declarations.empty?
		writer.write(declarations)
		puts io.string
	end
end

private

# Convert a class definition to RBS.
def class_to_rbs(definition, method_definitions = [], index = nil)
	name = qualified_name_to_rbs(definition.qualified_name)
	comment = extract_comment(definition)
	
	# Build method definitions
	methods = method_definitions.map { |method_def| method_to_rbs(method_def, index) }.compact
	
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
	name = qualified_name_to_rbs(definition.qualified_name)
	comment = extract_comment(definition)
	
	# Build method definitions
	methods = method_definitions.map { |method_def| method_to_rbs(method_def, index) }.compact
	
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
		block: nil,
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
		parse_type_string(type_string, definition, index)
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
		type = parse_type_string(type_string, definition, index)
		
		RBS::Types::Function::Param.new(
			type: type,
			name: name.to_sym
		)
	end
end

# Infer return type based on method patterns and heuristics.
def infer_return_type(definition)
	method_name = definition.name
	
	# Methods ending with ? are typically boolean
	if method_name.end_with?('?')
		return RBS::Types::Union.new(types: [
			RBS::Types::ClassInstance.new(name: RBS::TypeName.new(name: :TrueClass, namespace: RBS::Namespace.root), args: [], location: nil),
			RBS::Types::ClassInstance.new(name: RBS::TypeName.new(name: :FalseClass, namespace: RBS::Namespace.root), args: [], location: nil)
		], location: nil)
	end
	
	# Methods named initialize return void
	if method_name == 'initialize'
		return RBS::Types::Bases::Void.new(location: nil)
	end
	
	# Methods with names that suggest they return self
	if method_name.match?(/^(add|append|prepend|push|<<|concat|merge!|sort!|reverse!|clear|delete|remove)/)
		return RBS::Types::Bases::Self.new(location: nil)
	end
	
	# Default to untyped
	RBS::Types::Bases::Any.new(location: nil)
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

# Parse a type string and convert it to RBS type using RBS's built-in parser.
def parse_type_string(type_string, definition = nil, index = nil)
	# Clean up the type string
	type_string = type_string.strip
	
	# Convert () to [] for generic types as suggested
	normalized_type_string = type_string.gsub('(', '[').gsub(')', ']')
	
	# Handle special cases that need inference
	case normalized_type_string
	when /^void$/i
		return RBS::Types::Bases::Void.new(location: nil)
	when /^nil$/i
		return RBS::Types::Bases::Nil.new(location: nil)
	when /^self$/i
		return RBS::Types::Bases::Self.new(location: nil)
	when /^untyped$/i
		return RBS::Types::Bases::Any.new(location: nil)
	when /^Boolean$/i
		return RBS::Types::Union.new(types: [
			RBS::Types::ClassInstance.new(name: RBS::TypeName.new(name: :TrueClass, namespace: RBS::Namespace.root), args: [], location: nil),
			RBS::Types::ClassInstance.new(name: RBS::TypeName.new(name: :FalseClass, namespace: RBS::Namespace.root), args: [], location: nil)
		], location: nil)
	end
	
	# Try to parse with RBS's built-in parser
	begin
		parsed_type = RBS::Parser.parse_type(normalized_type_string)
		
		# If we have an index and definition, try to resolve relative references
		if index && definition && parsed_type.is_a?(RBS::Types::ClassInstance)
			resolved_type = resolve_type_with_index(type_string, definition, index)
			return resolved_type if resolved_type
		end
		
		return parsed_type
	rescue => e
		# If parsing fails, try to resolve with index if available
		if index && definition
			resolved_type = resolve_type_with_index(type_string, definition, index)
			return resolved_type if resolved_type
		end
		
		# Fall back to untyped
		return RBS::Types::Bases::Any.new(location: nil)
	end
end

# Resolve a type string using the index and definition context.
def resolve_type_with_index(type_string, definition, index)
	# Skip if already fully qualified or a built-in type
	return nil if type_string.start_with?('::') || type_string.match?(/^[a-z]/)
	
	# Try to find the type in the index
	begin
		reference = Decode::Language::Ruby::Reference.new(type_string)
		resolved_definition = index.lookup(reference, relative_to: definition)
		
		if resolved_definition
			qualified_name = resolved_definition.qualified_name
			parts = qualified_name.split('::')
			name = parts.pop
			namespace = if parts.empty?
				RBS::Namespace.root
			else
				RBS::Namespace.new(path: parts.map(&:to_sym), absolute: true)
			end
			
			return RBS::Types::ClassInstance.new(
				name: RBS::TypeName.new(name: name.to_sym, namespace: namespace),
				args: [],
				location: nil
			)
		end
	rescue => e
		# If resolution fails, return nil to fall back to default parsing
		return nil
	end
	
	nil
end

# Convert a qualified name to RBS TypeName.
def qualified_name_to_rbs(qualified_name)
	parts = qualified_name.split("::")
	name = parts.pop
	namespace = RBS::Namespace.new(path: parts.map(&:to_sym), absolute: true)
	
	RBS::TypeName.new(name: name.to_sym, namespace: namespace)
end 