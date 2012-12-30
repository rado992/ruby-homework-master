class Integer
  def is_prime?
    2.upto(pred).all? { |i| remainder(i).nonzero? }
  end

  def prime_divisors
    2.upto(abs).select do
      remainder(n).zero? and n.is_prime?
    end
  end
end


class Range
  def fizzbuzz
    map do |n|
      if (n % 15).zero? then :fizzbuzz
      elsif (n % 5).zero? then :buzz
      elsif (n % 3).zero? then :fizz
      else n
      end
    end
  end
end

class Hash
  def group_values
    each_with_object({}) do |(key, value), hash|
      hash[value] ||= []
      hash[value] << key
    end
  end
end

p = { a: 4, b: 2, c: 1, d: 4 }
p p.group_values

class Array
  def densities
    map do |element|
      count element
    end
  end
end
