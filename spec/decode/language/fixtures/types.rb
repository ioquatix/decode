
require 'parser/current'
require 'ast/node'

require 'trenni/strings'

module Decode
	module Code

		

		
		def self.append_const(node, path = [])
			parent, name = node.children
			
			if parent
				append_const(parent, path)
			end
			
			path << name
			
			return path
		end

		def self.wrap(node)
			case node&.type
			when :send
				path = append_const(node)
				
				children = node.children[2..].map{|node| wrap(node)}
				
				return Node.wrap(node, children, "send definition for #{path.join('-')}")
			when :const
				path = append_const(node)
				
				return Node.wrap(node, nil, "definition for #{path.join('-')}")
			else
				return node
			end
		end

		def self.parse(text)
			top = ::Parser::CurrentRuby.parse(text)
			
			top = wrap(top) || top
		end
	end
end



text = "Foo(Bar, Baz, true)"

top = Decode::Code.parse(text)

binding.irb
