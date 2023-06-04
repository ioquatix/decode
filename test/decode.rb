# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020, by Samuel Williams.

require 'decode/version'

describe Decode do
	it "has a version number" do
		expect(Decode::VERSION).to be =~ /\d+\.\d+\.\d+/
	end
end
