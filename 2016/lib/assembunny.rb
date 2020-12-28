class AssemBunny
  def initialize(file)
    @code = File.read(file).strip.split("\n").map do |line|
      case line
      when /\Acpy (-?\d+|[a-d]) ([a-d])\z/
        [ :cpy, reg_or_int(Regexp.last_match(1)), Regexp.last_match(2).to_sym ]
      when /\A(inc|dec) ([a-d])\z/
        [ Regexp.last_match(1).to_sym, Regexp.last_match(2).to_sym ]
      when /\Ajnz (-?\d+|[a-d]) (-?\d+|[a-d])\z/
        [ :jnz, reg_or_int(Regexp.last_match(1)), reg_or_int(Regexp.last_match(2)) ]
      else
        raise "Malformed line: '#{line}'"
      end
    end
  end

  private
  def reg_or_int(arg)
    if ('a'..'d').include?(arg)
      return arg.to_sym
    else
      return arg.to_i
    end
  end

  public
  def run(a: 0, b: 0, c: 0, d: 0)
    ip = 0
    reg = { a: a, b: b, c: c, d: d }
    while ip < @code.length
      next_ip = ip + 1
      instr, arg1, arg2 = @code[ip]
      case instr
      when :cpy
        reg[arg2] = (reg[arg1] or arg1)
      when :inc
        reg[arg1] += 1
      when :dec
        reg[arg1] -= 1
      when :jnz
        if (reg[arg1] or arg1) != 0
          next_ip = ip + (reg[arg2] or arg2)
        end
      else
        raise "Unknown instruction: '#{instr}'"
      end
      ip = next_ip
    end
    return reg
  end
end
