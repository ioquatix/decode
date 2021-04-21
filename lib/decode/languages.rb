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

require_relative 'language/generic'
require_relative 'language/ruby'

module Decode
	# A context for looking up languages based on file extension or name.
	class Languages
		def self.all
			self.new.tap do |languages|
				languages.add(Language::Ruby.new)
			end
		end
		
		def initialize
			@named = {}
			@extensions = {}
		end
		
		def freeze
			return unless frozen?
			
			@named.freeze
			@extensions.freeze
			
			super
		end
		
		def add(language)
			language.names.each do |name|
				@named[name] = language
			end
			
			language.extensions.each do |extension|
				@extensions[extension] = language
			end
		end
		
		def fetch(name)
			@named.fetch(name) do
				unless @named.frozen?
					@named[name] = Language::Generic.new(name)
				end
			end
		end
		
		def source_for(path)
			extension = File.extname(path)
			
			if language = @extensions[extension]
				Source.new(path, language)
			end
		end
		
		REFERENCE = /\A(?<name>[a-z]+)?\s+(?<identifier>.*?)\z/
		
		# Parse a language agnostic reference:
		# e.g. `ruby MyModule::MyClass`
		#
		def parse_reference(text, default_language: nil)
			if match = REFERENCE.match(text)
				language = self.fetch(match[:name]) || default_language
				
				return language.reference_for(match[:identifier])
			elsif default_language
				return default_language.reference_for(text)
			end
		end
		
		def reference_for(name, identifier)
			self.fetch(name).reference_for(identifier)
		end
	end
end
