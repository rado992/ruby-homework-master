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
    oldhash = self
    newhash = Hash.new
    curkeys = []
    curval = 0
    is_included = false

    oldhash.each do |key, val|
      curval = val

      newhash.each do |nkey, nval|
        if nval == val
          is_included = true
        end
      end

      oldhash.each do |tempkey, tempval|
        if is_included == false and (curval == tempval)
          curkeys << tempkey
        end
      end

      newhash = newhash.merge({curval => curkeys})
      curkeys = []
      is_included = false
    end
    newhash
  end
end

class Array
  def densities
    symbols = self
    counts = []
    cnt = 0
    temp = 0
    symbols.each do |sym|
      cnt = cnt + 1
    end
    cnt = cnt - 1
    0.upto cnt do |x|
      0.upto cnt do |y|
        if symbols[x] == symbols[y]
          temp = temp + 1
        end
      end
      counts << temp
      temp = 0
    end
    counts
  end
end
