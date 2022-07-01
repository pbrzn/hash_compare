require 'spec_helper'
require './lib/compare_hashes.rb'

RSpec.describe "Compare Hashes" do
  describe "initialization" do
    a = { "a": 1 }
    b = { "b": 2 }
    c = CompareHashes.new(a, b)

    it "initializes with two hashes" do
      expect(c).to be_an_instance_of(CompareHashes)
    end

    it "is initialized and called with two hashes" do
      expect(c).to respond_to(:call)
    end
  end

  describe "" do
    it "" do
      
    end
  end
end
