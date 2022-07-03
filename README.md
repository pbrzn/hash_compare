# Hash Compare

A simple solution for comparing hashes in Ruby.

## Instructions

Fork and clone this repo, then navigate to the newly created <b>Hash Compare</b> directory and run `bundle install` in your terminal. This will install any necessary dependencies.

While still in the <b>Hash Compare</b> directory, open <b>IRB</b> in your terminal and type `require './lib/compare_hashes.rb'`. You can now avail yourself to the CompareHashes class.

Create a new instance of CompareHashes via `CompareHashes.new` and add two hashes as arguments. You also have the option of adding a third argument: a string stating either "shallow" or "deep". This indicates to the instance whether you would like to do a <i>shallow</i> comparison of the two hashes or a <i>deep</i> comparison.

NOTE: Requirements for hashes are as follows...
  1) Keys must be strings. Because of this, it is best to use the `=>` syntax, as Ruby automatically changes key types to symbols when you use a colon.
  2) Values can be the following types: String, Boolean (TrueClass or FalseClass), Number (Integer or Float), Hash and Array.
Using incorrect key or value types will raise a TypeError.

To activate and print the results of the comparison, simply call HashCompare's #call method on the newly created instance.

Ex:
```
CompareHashes.new(
  {
    "a" => 6,
    "b" => ["This", "is", "cool!"],
    "c" => {
      "d" => true
      }
  },
  {
    "a" => 6,
    "b" => ["This", "is", "great!"],
    "c" => {
      "d" => false
      }
  }, "deep").call
```
  
This will print/return a result that looks like this:

```
The array element at index 2, at the key 'b' in both hashes differ...
___1st Hash___
At b: array[2] is cool!
___2nd Hash___
At b: array[2] is great!
----------------------------------------------------
This key common to both hashes has differing values in each hash.
___1st Hash___
c --> d: true
___2nd Hash___
c --> d: false
----------------------------------------------------
These hashes are not equal.
 => false
```
### To Run Test Suite

In the command line, simply type the command `bundle exec rspec spec/compare_hashes.rb` to run the RSpec test suite.
