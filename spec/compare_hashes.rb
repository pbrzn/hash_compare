require 'spec_helper'
require './lib/compare_hashes.rb'

RSpec.describe "Compare Hashes" do
  describe "Initialization" do
    a = { "a" => 1 }
    b = { "b" => 2 }
    c = CompareHashes.new(a, b)

    it "initializes with two hashes" do
      expect(c).to be_an_instance_of(CompareHashes)
    end

    it "is initialized and called with two hashes" do
      expect(c).to respond_to(:call)
    end
  end

  describe "Type Errors" do
    it "#Call throws an error if any keys are not strings" do
      a = { "a" => 1, "b" => 2, "c" => "3" }
      b = { "a" => 1, "b" => 2, :c => "3"}
      c = CompareHashes.new(a, b)
      expect{ c.call }.to raise_error(TypeError, /All keys must be Strings./)
    end

    it "#Call throws an error if any values are not accepted types" do
      a = { "a" => Time.now, "b" => 2, "c" => "3" }
      b = { "a" => 1, "b" => 2, "c" => "3"}
      c = CompareHashes.new(a, b)
      expect{ c.call }.to raise_error(TypeError, /The following value types are acceptable: String, Boolean, Number, Hash, Array./)
    end
  end

  describe "Comparing Keys" do
    it "#Call returns true if keys (and values) match" do
      a = { "a" => 1, "b" => 2, "c" => "3" }
      b = { "a" => 1, "b" => 2, "c" => "3" }
      c = CompareHashes.new(a, b)
      expect(c.call).to be true
      expect{ c.call }.to output("Both hashes are equal!\n").to_stdout
    end

    it "#Call returns false if one hash has more key/value pairs than the other" do
      a = { "a" => 1, "b" => 2, "c" => "3" }
      b = { "a" => 1, "b" => 2, "c" => "3", "d" => 4}
      c = CompareHashes.new(a, b)
      expect(c.call).to be false
      expect{ c.call }.to output("These are the key/value pairs from Hash Two that do not appear in Hash One:\nd: 4\n----------------------------------------------------\nThese hashes are not equal.\n").to_stdout

      a = { "a" => 1, "b" => 2, "c" => "3", "d" => 4, "e" => [5] }
      b = { "a" => 1, "b" => 2, "c" => "3"}
      c = CompareHashes.new(a, b)
      expect(c.call).to be false
      expect{ c.call }.to output("These are the key/value pairs from Hash One that do not appear in Hash Two:\nd: 4\ne: [5]\n----------------------------------------------------\nThese hashes are not equal.\n").to_stdout
    end

    it "#Call returns false if keys do not match" do
      a = { "a" => 1, "b" => 2, "c" => "3" }
      b = { "a" => 1, "d" => 2, "e" => "3" }
      c = CompareHashes.new(a, b)
      expect(c.call).to be false
      expect{ c.call }.to output("These are the key/value pairs from Hash One that do not appear in Hash Two:\nb: 2\nc: 3\n----------------------------------------------------\nThese are the key/value pairs from Hash Two that do not appear in Hash One:\nd: 2\ne: 3\n----------------------------------------------------\nThese hashes are not equal.\n").to_stdout
    end
  end

  describe "Comparing Values: Shallow Comparison" do
    it "#Call returns true if both hashes' keys & values are equal, without 3rd argument" do
      a = { "a" => 1, "b" => 2, "c" => "3", "d" => [4,5,[6,7]], "e" => true, "f" => { "g" => false }  }
      b = { "a" => 1, "b" => 2, "c" => "3", "d" => [4,5,[6,7]], "e" => true, "f" => { "g" => false }  }
      c = CompareHashes.new(a, b)
      expect(c.call).to be true
      expect{ c.call }.to output("Both hashes are equal!\n").to_stdout
    end

    it "#Call returns true if both hashes' keys & values are equal, with 3rd argument: 'shallow'" do
      a = { "a" => 1, "b" => 2, "c" => "3", "d" => [4,5,[6,7]], "e" => true, "f" => { "g" => false } }
      b = { "a" => 1, "b" => 2, "c" => "3", "d" => [4,5,[6,7]], "e" => true, "f" => { "g" => false } }
      c = CompareHashes.new(a, b, 'shallow')
      expect(c.call).to be true
      expect{ c.call }.to output("Both hashes are equal!\n").to_stdout
    end

    it "#Call returns false if both hashes' keys & values are not equal, without 3rd argument" do
      a = { "a" => 1, "b" => 2, "c" => "3" }
      b = { "a" => 4, "b" => 5, "c" => "6" }
      c = CompareHashes.new(a, b)
      expect(c.call).to be false
      expect{ c.call }.to output("This key common to both hashes has differing values in each hash.\n___1st Hash___\na: 1\n___2nd Hash___\na: 4\n----------------------------------------------------\nThis key common to both hashes has differing values in each hash.\n___1st Hash___\nb: 2\n___2nd Hash___\nb: 5\n----------------------------------------------------\nThis key common to both hashes has differing values in each hash.\n___1st Hash___\nc: 3\n___2nd Hash___\nc: 6\n----------------------------------------------------\nThese hashes are not equal.\n").to_stdout
    end

    it "#Call returns false if both hashes' keys & values are not equal, with 3rd argument: 'shallow'" do
      a = { "a" => 1, "b" => 2, "c" => "3" }
      b = { "a" => 4, "b" => 5, "c" => "6" }
      c = CompareHashes.new(a, b, 'shallow')
      expect(c.call).to be false
      expect{ c.call }.to output("This key common to both hashes has differing values in each hash.\n___1st Hash___\na: 1\n___2nd Hash___\na: 4\n----------------------------------------------------\nThis key common to both hashes has differing values in each hash.\n___1st Hash___\nb: 2\n___2nd Hash___\nb: 5\n----------------------------------------------------\nThis key common to both hashes has differing values in each hash.\n___1st Hash___\nc: 3\n___2nd Hash___\nc: 6\n----------------------------------------------------\nThese hashes are not equal.\n").to_stdout
    end

    it "#Call returns false if values match, but value types do not" do
      a = { "a" => 1, "b" => 2, "c" => "3" }
      b = { "a" => 1, "b" => 2, "c" => 3 }
      c = CompareHashes.new(a, b, 'shallow')
      expect(c.call).to be false
      expect{ c.call }.to output("This key common to both hashes has the same values, but of two different types\n___1st Hash___\nc: 3, where 3's type is String\n___2nd Hash___\nc: 3, where 3's type is Integer\n----------------------------------------------------\nThese hashes are not equal.\n").to_stdout
    end

    it "#Call shallow compares Array and Hash values" do
      a = { "a" => [4,5,[6,7]], "b" => true, "c" => { "d" => "Right!" } }
      b = { "a" => [2,4,[6,8]], "b" => false, "c" => { "d" => "Wrong." } }
      c = CompareHashes.new(a, b, 'shallow')
      expect(c.call).to be false
      expect{ c.call }.to output("This key common to both hashes has differing values in each hash.\n___1st Hash___\na: [4, 5, [6, 7]]\n___2nd Hash___\na: [2, 4, [6, 8]]\n----------------------------------------------------\nThis key common to both hashes has differing values in each hash.\n___1st Hash___\nb: true\n___2nd Hash___\nb: false\n----------------------------------------------------\nThis key common to both hashes has differing values in each hash.\n___1st Hash___\nc: {\"d\"=>\"Right!\"}\n___2nd Hash___\nc: {\"d\"=>\"Wrong.\"}\n----------------------------------------------------\nThese hashes are not equal.\n").to_stdout
    end
  end

  describe "Comparing Values: Deep Comparison" do
    it "#Call returns true if both hashes' keys & values are equal, with 3rd argument: 'deep'" do
      a = { "a" => [4,5,[6,7]], "b" => true, "c" => { "d" => false } }
      b = { "a" => [4,5,[6,7]], "b" => true, "c" => { "d" => false } }
      c = CompareHashes.new(a, b, 'deep')
      expect(c.call).to be true
      expect{ c.call }.to output("Both hashes are equal!\n").to_stdout
    end

    it "#Call returns false if both hashes' keys & values are not equal, with 3rd argument: 'deep'" do
      a = { "a" => [4,5,[6,7]], "b" => true, "c" => { "d" => { "e" => true } } }
      b = { "a" => [4,6,[8,10]], "b" => true, "c" => { "d" => { "e" => false } } }
      c = CompareHashes.new(a, b, 'deep')
      expect(c.call).to be false
      expect{ c.call }.to output("The array element at index 1, at the key 'a' in both hashes differ...\n___1st Hash___\nAt a: array[1] is 5\n___2nd Hash___\nAt a: array[1] is 6\n----------------------------------------------------\nThe array element at index 0, at the key 'a --> array[2]' in both hashes differ...\n___1st Hash___\nAt a --> array[2]: array[0] is 6\n___2nd Hash___\nAt a --> array[2]: array[0] is 8\n----------------------------------------------------\nThe array element at index 1, at the key 'a --> array[2]' in both hashes differ...\n___1st Hash___\nAt a --> array[2]: array[1] is 7\n___2nd Hash___\nAt a --> array[2]: array[1] is 10\n----------------------------------------------------\nThese hashes are not equal.\n").to_stdout
    end

    it "#Call deeply compares types in nested elements" do
      a = { "a" => [4,5,["6",7]], "b" => true, "c" => { "d" => { "e" => false } } }
      b = { "a" => [4,5,[6,7]], "b" => true, "c" => { "d" => { "e" => "false" } } }
      c = CompareHashes.new(a, b, 'deep')
      expect(c.call).to be false
      expect{ c.call }.to output("The array elements at index 0, at the key 'a --> array[2]' in both hashes differ in type...\n___1st Hash___\nAt a --> array[2]: array[0] is 6. It's type is String\n___2nd Hash___\nAt a --> array[2]: array[0] is 6. It's type is Integer\n----------------------------------------------------\nThis key common to both hashes has the same values, but of two different types\n___1st Hash___\nc --> d --> e: false, where false's type is FalseClass\n___2nd Hash___\nc --> d --> e: false, where false's type is String\n----------------------------------------------------\nThese hashes are not equal.\n").to_stdout
    end

    it "#Call compares deeply nested elements" do
      a = { "a" => [4,5,[6,7,[8,9,[10]]]], "b" => true, "c" => { "d" => { "e" => {"f" => {"g" => false } } } } }
      b = { "a" => [4,5,[6,7,[8,9,[10]]]], "b" => true, "c" => { "d" => { "e" => {"f" => {"g" => false } } } } }
      c = CompareHashes.new(a, b, 'deep')
      expect(c.call).to be true
      expect{ c.call }.to output("Both hashes are equal!\n").to_stdout

      d = { "a" => [4,5,[6,7,[8,9,[10]]]], "b" => true, "c" => { "d" => { "e" => {"f" => {"g" => {"h" => "This is deep!" } } } } } }
      e = { "a" => [4,5,[6,7,[8,9,[11]]]], "b" => true, "c" => { "d" => { "e" => {"f" => {"g" => true } } } } }
      f = CompareHashes.new(d, e, 'deep')
      expect(f.call).to be false
      expect{ f.call }.to output("The array element at index 0, at the key 'a --> array[2] --> array[2] --> array[2]' in both hashes differ...\n___1st Hash___\nAt a --> array[2] --> array[2] --> array[2]: array[0] is 10\n___2nd Hash___\nAt a --> array[2] --> array[2] --> array[2]: array[0] is 11\n----------------------------------------------------\nThis key common to both hashes has differing values in each hash.\n___1st Hash___\nc --> d --> e --> f --> g: {\"h\"=>\"This is deep!\"}\n___2nd Hash___\nc --> d --> e --> f --> g: true\n----------------------------------------------------\nThese hashes are not equal.\n").to_stdout
    end

    it "Will throw a Type Error on a deeply nested element" do
      a = { "a" => [4,5,[6,7,[8,9,[10]]]], "b" => true, "c" => { "d" => { "e" => {"f" => {"g" => false } } } } }
      b = { "a" => [4,5,[6,7,[8,9,[Time.now]]]], "b" => true, "c" => { "d" => { "e" => {"f" => {"g" => false } } } } }
      c = CompareHashes.new(a, b, 'deep')
      expect{ c.call }.to raise_error(TypeError, /The following value types are acceptable: String, Boolean, Number, Hash, Array./)
    end
  end
end
