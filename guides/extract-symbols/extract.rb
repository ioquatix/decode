#!/usr/bin/env ruby

# This example demonstrates how to extract symbols using the index. An instance of {Decode::Index} is used for loading symbols from source code files. These symbols are available as a flat list and as a trie structure. You can look up specific symbols using a reference using {Decode::Index#lookup}.
require_relative '../../lib/decode/index'

# Firstly, construct the index:
index = Decode::Index.new

# Then, update the index by loading paths from the file system:
paths = Dir.glob(File.expand_path("../../lib/**/*.rb", __dir__))
index.update(paths)

# Finally, you can print out the loaded symbols:
index.symbols.each do |name, symbol|
	puts symbol.long_form
end

# Lookup a specific symbol:
absolute_reference = Decode::Language::Ruby.reference("Decode::Index:lookup")
lookup_symbol = index.lookup(absolute_reference).first
puts lookup_symbol.long_form

# Lookup a method relative to that symbol:
relative_reference = Decode::Language::Ruby.reference("trie")
trie_attribute = index.lookup(relative_reference, relative_to: lookup_symbol).first
puts trie_attribute.long_form
