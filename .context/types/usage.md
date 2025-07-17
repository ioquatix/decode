# Usage

The Types gem provides abstract types for the Ruby programming language that can be used for documentation and evaluation purposes. It offers a simple and Ruby-compatible approach to type signatures, designed to work seamlessly with documentation tools and argument parsing.

## Overview

This gem provides a simple and Ruby-compatible approach to type information. It offers:

- Simple type signature parsing.
- String-to-value coercion.
- Documentation integration.
- RBS compatibility.

The types are designed to be a subset of Ruby's type system, making them easy to understand and use while remaining powerful enough for most use cases.

## How to Use Types

Types can be used directly as modules or classes:

```ruby
# Simple types
Types::String.parse("hello")     # => "hello"
Types::Integer.parse("42")       # => 42
Types::Float.parse("3.14")       # => 3.14
Types::Boolean.parse("true")     # => true
Types::Symbol.parse("hello")     # => :hello
```

### Composite Types

For more complex types, you can create composite types:

```ruby
# Array with specific item type
array_type = Types::Array(Types::Integer)
array_type.parse(["1", "2", "3"])  # => [1, 2, 3]

# Hash with key and value types
hash_type = Types::Hash(Types::String, Types::Integer)
hash_type.parse("a:1,b:2")        # => {"a" => 1, "b" => 2}

# Tuple types
tuple_type = Types::Tuple(Types::String, Types::Integer)
tuple_type.parse("hello,42")      # => ["hello", 42]
```

### Union Types

You can create union types using the `|` operator:

```ruby
# String or Integer
string_or_int = Types::String | Types::Integer
string_or_int.parse("hello")      # => "hello"
string_or_int.parse("42")         # => 42
```

## How to Parse Types

The main way to parse type signatures is using `Types.parse`:

```ruby
# Simple types
Types.parse("String")                    # => Types::String
Types.parse("Integer")                   # => Types::Integer
Types.parse("Float")                     # => Types::Float

# Composite types
Types.parse("Array(String)")             # => Types::Array(Types::String)
Types.parse("Hash(String, Integer)")     # => Types::Hash(Types::String, Types::Integer)
Types.parse("Tuple(String, Integer)")    # => Types::Tuple(Types::String, Types::Integer)

# Union types
Types.parse("String|Integer")            # => Types::Any([Types::String, Types::Integer])
```

### Type Signature Format

The gem supports a subset of Ruby expressions for type signatures:

- Simple types: `String`, `Integer`, `Float`, `Boolean`, `Symbol`, `Nil`
- Composite types: `Array(Type)`, `Hash(KeyType, ValueType)`, `Tuple(Type1, Type2)`
- Union types: `Type1|Type2`
- Lambda types: `Lambda(ArgType, returns: ReturnType)`

### Validation

Type signatures are validated against a regex pattern:

```ruby
Types::VALID_SIGNATURE = /\A[a-zA-Z\(\):,_|\s]+\z/
```

Invalid signatures will raise an `ArgumentError`:

```ruby
Types.parse("Invalid@Type")  # => ArgumentError: Invalid type signature: "Invalid@Type"!
```

## How to Use Types to Parse Strings into Values

Each type provides a `parse` method that can convert strings to typed values:

```ruby
# Integer parsing
Types::Integer.parse("42")        # => 42
Types::Integer.parse("0")         # => 0
Types::Integer.parse("-123")      # => -123

# String parsing (converts any input to string)
Types::String.parse(42)           # => "42"
Types::String.parse("hello")      # => "hello"

# Float parsing
Types::Float.parse("3.14")        # => 3.14
Types::Float.parse("0.0")         # => 0.0

# Boolean parsing
Types::Boolean.parse("true")      # => true
Types::Boolean.parse("false")     # => false
Types::Boolean.parse("1")         # => true
Types::Boolean.parse("0")         # => false
```

### Array Parsing

Arrays can parse both string representations and actual arrays:

```ruby
array_type = Types::Array(Types::Integer)

# Parse string representation
array_type.parse("1,2,3")         # => [1, 2, 3]
array_type.parse("'a','b','c'")   # => ["a", "b", "c"]

# Parse actual array
array_type.parse(["1", "2", "3"]) # => [1, 2, 3]
```

### Hash Parsing

Hashes can parse string representations:

```ruby
hash_type = Types::Hash(Types::String, Types::Integer)

# Parse string representation
hash_type.parse("a:1,b:2,c:3")    # => {"a" => 1, "b" => 2, "c" => 3}
```

### Error Handling

Parsing methods will raise `ArgumentError` for invalid inputs:

```ruby
Types::Integer.parse("not_a_number")  # => ArgumentError
Types::Array(Types::Integer).parse("invalid")  # => ArgumentError
```

### Practical Example: Command Line Arguments

This is particularly useful for parsing command line arguments:

```ruby
def parse_arguments(arguments)
  config = {
    port: Types::Integer.parse(arguments[:port] || "8080"),
    host: Types::String.parse(arguments[:host] || "localhost"),
    debug: Types::Boolean.parse(arguments[:debug] || "false"),
    tags: Types::Array(Types::String).parse(arguments[:tags] || "")
  }
  
  config
end

# Usage
parse_arguments(port: "3000", tags: "api,web,admin")
# => {port: 3000, host: "localhost", debug: false, tags: ["api", "web", "admin"]}
```

### Integration with Documentation

The types work seamlessly with documentation tools that use `@parameter` and `@returns` comments:

```ruby
# @parameter port [Integer] The port number to bind to
# @parameter host [String] The host address to bind to
# @parameter tags [Array(String)] List of tags to apply
# @returns [Hash] Configuration hash
def create_server(port, host, tags)
  # Implementation here
end
```

This provides a clean, consistent way to handle type information throughout your Ruby applications.
