module AOCMath

  # Applied algebra... :)
  # a*x^2 + b* + c = 0
  # x = -b/(2*a) +/- sqrt(D), D = (b/2*a)^2 - c/a >= 0
  def self.quadratic_solutions(a, b, c)
    if a != 0
      d = (b / (2.0 * a))**2 - c/a.to_f
      return [] if d < 0 # I'd rather avoid complex numbers...
      neg_b_div_2a = -b / (2.0 * a)
      return [ neg_b_div_2a ] if d == 0
      d_sqrt = Math.sqrt(d)
      return [ neg_b_div_2a - d_sqrt, neg_b_div_2a + d_sqrt ]
    elsif b != 0
      # a = 0 => Linear function
      return [ -c / b.to_f ]
    elsif c != 0
      # This function is constant, but not 0...
      return []
    else
      # a = b = c = 0, any x is a valid solution
      return nil
    end
  end

end
