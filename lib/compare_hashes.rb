class CompareHashes
  attr_reader :call

  def initialize(hash_one, hash_two, options = 'shallow')
    @hash_one = hash_one
    @hash_two = hash_two
    @options = options
  end

  def call
    if @hash_one.keys.any? {|k| k.class != String } || @hash_two.keys.any? {|k| k.class != String }
      raise TypeError.new "All keys must be Strings."
      puts error.message
    elsif @hash_one.empty? && @hash_two.empty?
      puts "Both hashes are empty."
    end

    puts "1st Hash: #{@hash_one}"
    puts "2nd Hash: #{@hash_two}"

    if !!compare_keys && !!compare_values
      puts "Both hashes are equal!"
    else
      puts "These hashes are not equal."
    end
  end

  def compare_keys
    one = @hash_one.keys
    two = @hash_two.keys

    if one == two
      return true
    else
      one_diffs = @hash_one.filter {|k,v| !@hash_two[k] }
      two_diffs = @hash_two.filter {|k,v| !@hash_one[k] }

      if one_diffs.length > 0
        puts "These are the key/value pairs from Hash One that do not appear in Hash Two:"
        one_diffs.each {|k,v| puts "#{k}: #{v}" }
      end

      if two_diffs.length > 0
        puts "These are the key/value pairs from Hash Two that do not appear in Hash One:"
        two_diffs.each {|k,v| puts "#{k}: #{v}" }
      end
    end
    false
  end

  def compare_values

    if !value_type_validator(@hash_one.values) || !value_type_validator(@hash_two.values)
      raise TypeError.new "The following value types are acceptable: String, Boolean, Number (Integer or Float), Hash, Array."
      puts error.message
    end

    one_types = @hash_one.values.map {|v| v.class }
    two_types = @hash_two.values.map {|v| v.class }

    if @options == 'shallow' && @hash_one.values == @hash_two.values && one_types == two_types
      return true
    elsif @options == 'shallow'
      shallow = @hash_one.keys.map {|k| self.shallow_compare({ "#{k}" => @hash_one[k] }, { "#{k}" => @hash_two[k] }) }
      shallow.any? {|v| v == false } ? false : true
    elsif @options == 'deep'
      deep = @hash_one.keys.map {|k| self.deep_compare({ "#{k}" => @hash_one[k] }, { "#{k}" => @hash_two[k] }) }
      deep.any? {|v| v == false } ? false : true
    end
  end

  def deep_compare(element_one, element_two)
    key = element_one.keys.first
    one = element_one.values.first
    two = element_two.values.first

    if one.class == Array && two.class == Array

      if one.length > two.length
        extra = one[two.length..one.length - 1]
        puts "The following elements of the array at key #{key} of the 1st has do not appear in the array at the same key in the 2nd hash..."
        extra.each_with_index {|v, i| puts "Index: #{i}, Value: #{v}" }
      elsif one.length < two.length
        extra = two[one.length..two.length - 1]
        puts "The following elements of the array at key #{key} of the 2nd has do not appear in the array at the same key in the 1st hash..."
        extra.each_with_index {|v, i| puts "Index: #{i}, Value: #{v}" }
      end

      one.each_with_index do |v, i|
        if !!two[i]
          if v.class == Hash && two[i].class == Hash
            CompareHashes.new(v, two[i], 'deep').call
          elsif v.class == Array && two[i].class == Array
            self.compare_nested_array_elements(v, two[i], key)
          elsif v != two[i]
            puts "The array element at index #{i}, at the key \'#{key}\' in both hashes differ..."
            puts "___1st Hash___"
            puts "At #{key}: array[#{i}] is #{v}"
            puts "___2nd Hash___"
            puts "At #{key}: array[#{i}] is #{two[i]}"
          end
        end
      end

    elsif one.class == Hash && two.class == Hash
      CompareHashes.new(one, two, 'deep').call
    else
      self.compare_with_key(element_one, element_two, key)
    end
  end

  def shallow_compare(element_one, element_two)
    key = element_one.keys.first
    val_one = element_one.values.first
    val_two = element_two.values.first

    self.compare_with_key(val_one, val_two, key)
  end

  def compare_with_key(one, two, key)
    if one.to_s == two.to_s && one.class != two.class
      puts "This key common to both hashes has the same values, but of two different types"
      puts "___1st Hash___"
      puts "#{key}: #{one}, where #{one}\'s type is #{one.class}"
      puts "___2nd Hash___"
      puts "#{key}: #{two}, where #{two}\'s type is #{two.class}"
      false
    elsif one != two
      puts "This key common to both hashes has differing values in each hash."
      puts "___1st Hash___"
      puts "#{key}: #{one}"
      puts "___2nd Hash___"
      puts "#{key}: #{two}"
      false
    else
      true
    end
  end

  def compare_nested_array_elements(one, two, key)
    if one.to_s == two.to_s && one.class != two.class
      puts "These elements in an array nested within the hashes differ in type..."
      puts "___From 1st Hash, nested in an array at the key \'#{key}\'___"
      puts "#{one}, where #{one}\'s type is #{one.class}"
      puts "___From 2nd Hash, nested in an array at the key \'#{key}\'___"
      puts "#{two}, where #{one}\'s type is #{one.class}"
      false
    elsif one != two
      puts "These elements in an array nested within the hashes differ in value..."
      puts "___1st Hash, nested in an array at the key \'#{key}\'___"
      puts "#{one}"
      puts "___2nd Hash, nested in an array at the key \'#{key}\'___"
      puts "#{two}"
      false
    else
      true
    end
  end

  def value_type_validator(values)
    values.each do |v|
      case v.class
      when String
        true
      when Integer
        true
      when TrueClass
        true
      when FalseClass
        true
      when Float
        true
      when Hash
        true
      when Array
        true
      else
        false
      end
    end
  end
end

# a = {"a" => 1, "b" => [2,3,4,[5, 6]], "c" => 3, "d" => 4, "e" => {"f" => 12, "g" => 19}}
# b = {"a" => 1, "b" => [2,7,4,[9, 8, 10]], "c" => 3, "d" => 4, "e" => {"f" => 12, "g" => 20}}
#
# CompareHashes.new(a, b, 'deep').call
