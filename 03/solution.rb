class Expr
  def self.build(tree)
    case tree[0]
    when :+ then Addition.new Expr.build(tree[1]), Expr.build(tree[2])
    when :* then Multiplication.new Expr.build(tree[1]), Expr.build(tree[2])
    when :- then Negation.new Expr.build(tree[1])
    when :sin then Sine.new Expr.build(tree[1])
    when :cos then Cosine.new Expr.build(tree[1])
    when :number then Number.new tree[1]
    when :variable then Variable.new tree[1]
    end
  end

  def ==(second_expr)
    equality = true
    if self.is_a?(Unary) && self.class == second_expr.class
      equality &= (self.operand == second_expr.operand)
    elsif self.is_a?(Binary) && self.class == second_expr.class
      equality &= (self.left_operand == second_expr.left_operand)
      equality &= (self.right_operand == second_expr.right_operand)
    else equality = false
    end
    equality
  end

  def +(second_expr)
    Addition.new(self, second_expr)
  end

  def *(second_expr)
    Multiplication.new(self, second_expr)
  end

  def -@
    Negation.new(self)
  end

end

class Unary < Expr
  attr_reader :operand
  def initialize(operand)
    @operand = operand
  end

  def simplify
    self
  end
end

class Binary < Expr
  attr_reader :left_operand, :right_operand
  def initialize(first_operand, second_operand)
    @left_operand, @right_operand = first_operand, second_operand
  end
end

class Number < Unary
  def evaluate(variable_hash)
    @operand
  end

  def derive(variable)
    Number.new(0)
  end
end

class Variable < Unary
  def simplify
    self
  end

  def evaluate(variable_hash)
    variable_hash.each do |key, replacement|
      if key == @operand
        return replacement
      end
    end
    raise "Variable not found!"
  end

  def derive(variable)
    variable == @operand ? Number.new(1) : Number.new(0)
  end
end

class Sine < Unary
  def simplify
    if @operand.is_a?(Number)
      Number.new(Math.sin(@operand.evaluate({})))
    else
      Sine.new(@operand.simplify)
    end
  end

  def evaluate(variable_hash)
    Math.sin(@operand.evaluate(variable_hash))
  end

  def derive(variable)
    Cosine.new(@operand).simplify
  end
end

class Cosine < Unary
  def simplify
    if @operand.is_a?(Number)
      Number.new(Math.cos(@operand.evaluate({})))
    else
      Cosine.new(@operand.simplify)
    end
  end

  def evaluate(variable_hash)
    Math.cos(@operand.evaluate(variable_hash))
  end

  def derive(variable)
    (-Sine.new(@operand).simplify).simplify
  end
end

class Negation < Unary
  def simplify
      -@operand.simplify
  end

  def evaluate(variable_hash)
    -1 * @operand.evaluate(variable_hash)
  end

  def derive(variable)
    -@operand.derive(variable).simplify
  end
end

class Addition < Binary
  def is_num_zero(expression)
    expression.is_a?(Number) && expression.evaluate({}) == 0
  end

  def both_are_numbers(left_operand, right_operand)
    (left_operand.is_a?(Number) and right_operand.is_a?(Number))
  end

  def new_number(left_oper, right_oper)
    Number.new left_oper.evaluate({}) + right_oper.evaluate({})
  end

  def simplify
      if is_num_zero(@left_operand) then @right_operand.simplify
      elsif is_num_zero(@right_operand) then @left_operand.simplify
      elsif both_are_numbers(@left_operand, @right_operand)
        new_number(@left_operand, @right_operand)
      else @left_operand.simplify + @right_operand.simplify
    end
  end

  def evaluate(variable_hash)
    left_eval = @left_operand.evaluate(variable_hash)
    right_eval = @right_operand.evaluate(variable_hash)
    left_eval + right_eval
  end

  def derive(variable)
    left_part = @left_operand.derive(variable).simplify
    right_part = @right_operand.derive(variable).simplify
    (left_part + right_part).simplify
  end
end

class Multiplication < Binary
  def is_num_zero(expression)
    expression.is_a?(Number) && expression.evaluate({}) == 0
  end

  def is_num_one(expression)
    expression.is_a?(Number) && expression.evaluate({}) == 1
  end

  def both_are_numbers(left_operand, right_operand)
    (left_operand.is_a?(Number) and right_operand.is_a?(Number))
  end

  def both_are_zeroes(left_operand, right_operand)
    (is_num_zero(left_operand.simplify) or is_num_zero(right_operand.simplify))
  end

  def simplify
    case
      when both_are_zeroes(@left_operand, @right_operand)
        Number.new(0)
      when is_num_one(@left_operand) then @right_operand.simplify
      when is_num_one(@right_operand) then @left_operand.simplify
      when both_are_numbers(@left_operand, @right_operand)
        Number.new (@left_operand.evaluate({}) * @right_operand.evaluate({}))
      else @left_operand.simplify * @right_operand.simplify
    end
  end

  def evaluate(variable_hash)
    @left_operand.evaluate(variable_hash) * @right_operand.evaluate(variable_hash)
  end

  def derive(variable)
    left_der = @left_operand.derive(variable).simplify
    left_func = @right_operand.simplify
    right_func = @left_operand.simplify
    right_der = @right_operand.derive(variable).simplify
    left_part = (left_der * left_part).simplify
    right_part = (right_part * right_der).simplify
    (left_part + right_part).simplify
  end
end
