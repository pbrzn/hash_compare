class CompareHashes
  attr_reader :call

  def initialize(hash_one, hash_two, options = 'shallow')
    @hash_one = hash_one
    @hash_two = hash_two
    @options = options
    @results = []
  end

  def call
    if @hash_one.keys.any? {|k| k.class != String } || @hash_two.keys.any? {|k| k.class != String }
      raise TypeError.new "All keys must be Strings."
      puts error.message
    elsif @hash_one.empty? && @hash_two.empty?
      puts "Both hashes are empty."
    end

    if compare_keys && compare_values && !@results.any? {|r| r == false }
      puts "Both hashes are equal!"
      return true
    else
      puts "These hashes are not equal."
      return false
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
        puts "----------------------------------------------------"
      end

      if two_diffs.length > 0
        puts "These are the key/value pairs from Hash Two that do not appear in Hash One:"
        two_diffs.each {|k,v| puts "#{k}: #{v}" }
        puts "----------------------------------------------------"
      end
    end
    false
  end

  def compare_values

    self.check_values_for_errors(@hash_one.values)
    self.check_values_for_errors(@hash_two.values)

    if @options == 'shallow'
      shallow = @hash_one.keys.each {|k| self.shallow_compare({ "#{k}" => @hash_one[k] }, { "#{k}" => @hash_two[k] }) }
    elsif @options == 'deep'
      deep = @hash_one.keys.each {|k| self.deep_compare({ "#{k}" => @hash_one[k] }, { "#{k}" => @hash_two[k] }) }
    end
  end

  def deep_compare(element_one, element_two)
    self.check_values_for_errors(element_one)
    self.check_values_for_errors(element_two)
    key = element_one.keys.first
    one = element_one.values.first
    two = element_two.values.first

    if one.class == Array && two.class == Array

      if one.length > two.length
        extra = one[two.length..one.length - 1]
        puts "The following elements of the array at key #{key} of the 1st has do not appear in the array at the same key in the 2nd hash..."
        extra.each_with_index {|v, i| puts "Index: #{i}, Value: #{v}" }
        puts "----------------------------------------------------"
        @results << false
      elsif one.length < two.length
        extra = two[one.length..two.length - 1]
        puts "The following elements of the array at key #{key} of the 2nd has do not appear in the array at the same key in the 1st hash..."
        extra.each_with_index {|v, i| puts "Index: #{i}, Value: #{v}" }
        puts "----------------------------------------------------"
        @results << false
      end

      one.each_with_index do |v, i|
        if two[i] != nil
          self.check_values_for_errors([v, two[i]])
          if v.class == Hash && two[i].class == Hash
            self.deep_compare(v, two[i])
          elsif v.class == Array && two[i].class == Array
            self.deep_compare({"#{key} --> array[#{i}]" => v}, {"#{key} --> array[#{i}]" => two[i]})
          elsif v.to_s == two[i].to_s && v.class != two[i].class
            puts "The array elements at index #{i}, at the key \'#{key}\' in both hashes differ in type..."
            puts "___1st Hash___"
            puts "At #{key}: array[#{i}] is #{v}. It's type is #{v.class}"
            puts "___2nd Hash___"
            puts "At #{key}: array[#{i}] is #{two[i]}. It's type is #{two[i].class}"
            puts "----------------------------------------------------"
            @results << false
          elsif v != two[i]
            puts "The array element at index #{i}, at the key \'#{key}\' in both hashes differ..."
            puts "___1st Hash___"
            puts "At #{key}: array[#{i}] is #{v}"
            puts "___2nd Hash___"
            puts "At #{key}: array[#{i}] is #{two[i]}"
            puts "----------------------------------------------------"
            @results << false
          end
        end
      end
    elsif one.class == Hash && two.class == Hash
      one.each do |k, v|
        if two[k] != nil
          self.deep_compare({ "#{key} --> #{k}" => v }, { "#{key} --> #{k}" => two[k] })
        end
      end

      if one.keys.length != two.keys.length
        one_diffs = one.filter {|k,v| !two[k] }
        two_diffs = two.filter {|k,v| !one[k] }

        if one_diffs.length > 0
          puts "These are the key/value pairs from the hash at the key #{key} from Hash One that do not appear at the same key in Hash Two:"
          one_diffs.each {|k,v| puts "#{key} => {#{k}: #{v}}" }
          puts "----------------------------------------------------"
          @results << false
        end

        if two_diffs.length > 0
          puts "These are the key/value pairs from the hash at the key #{key} from Hash Two that do not appear at the same key in Hash One:"
          two_diffs.each {|k,v| puts "#{key} => {#{k}: #{v}}" }
          puts "----------------------------------------------------"
          @results << false
        end
      end
    else
      self.compare_with_key(one, two, key)
    end
  end

  def shallow_compare(element_one, element_two)
    key = element_one.keys.first
    val_one = element_one.values.first
    val_two = element_two.values.first

    self.compare_with_key(val_one, val_two, key)
  end

  #---Direct element-to-element comparison---#
  def compare_with_key(one, two, key)
    self.check_values_for_errors([one, two])

    if one.to_s == two.to_s && one.class != two.class
      puts "This key common to both hashes has the same values, but of two different types"
      puts "___1st Hash___"
      puts "#{key}: #{one}, where #{one}\'s type is #{one.class}"
      puts "___2nd Hash___"
      puts "#{key}: #{two}, where #{two}\'s type is #{two.class}"
      puts "----------------------------------------------------"
      @results << false
    elsif one != two
      puts "This key common to both hashes has differing values in each hash."
      puts "___1st Hash___"
      puts "#{key}: #{one}"
      puts "___2nd Hash___"
      puts "#{key}: #{two}"
      puts "----------------------------------------------------"
      @results << false
    elsif one == two
      @results << true
    end
  end

  #---Value Type Checking & Error Raising---#
  def check_values_for_errors(values)
    values.each do |v|
      if value_type_validator(v) == false
        raise TypeError.new "The following value types are acceptable: String, Boolean, Number, Hash, Array."
        puts error.message
      end
    end
    false
  end

  def value_type_validator(value)
    case value
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
