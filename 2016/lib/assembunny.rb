require 'thread'

class AssemBunny
  ARG = '([[:lower:]]|-?\\d+)'
  def initialize(file)
    @code = File.read(file).strip.split("\n").map do |line|
      case line
      when /\A(cpy|jnz) #{ARG} #{ARG}\z/
        [ Regexp.last_match(1).to_sym, reg_or_int(Regexp.last_match(2)), reg_or_int(Regexp.last_match(3)) ]
      when /\A(inc|dec|tgl|out) #{ARG}\z/
        [ Regexp.last_match(1).to_sym, reg_or_int(Regexp.last_match(2)) ]
      else
        raise "Malformed line: '#{line}'"
      end
    end
    @code.each(&:freeze)
    @code.freeze
    @output = Queue.new
  end

  public
  def run(init_reg = {})
    @output.clear
    code = @code.dup
    ip = 0
    reg = Hash.new(0)
    reg.merge!(init_reg)
    while ip < code.length
      next_ip = ip + 1
      instr, arg1, arg2 = code[ip]
      case instr
      when :cpy
        if after_mul = skip_mul(arg1, arg2, code, ip, reg)
          next_ip = after_mul
        else
          set(reg, arg2, get(reg, arg1))
        end
      when :inc
        if after_add = skip_add(arg1, code, ip, reg)
          next_ip = after_add
        else
          set(reg, arg1, get(reg, arg1) + 1)
        end
      when :dec
        set(reg, arg1, get(reg, arg1) - 1)
      when :jnz
        if get(reg, arg1) != 0
          next_ip = ip + get(reg, arg2)
        end
      when :tgl
        i = ip + get(reg, arg1)
        if i < code.length
          tglinstr = code[i][0]
          case code[i].length
          when 2 # One argument
            tglinstr = (tglinstr == :inc ? :dec : :inc)
          when 3 # Two arguments
            tglinstr = (tglinstr == :jnz ? :cpy : :jnz)
          else
            raise "What in the world is this? #{new_instr.inspect}"
          end
          code[i] = [tglinstr, *code[i][1..-1]].freeze
        end
      when :out
        @output << get(reg, arg1)
      else
        raise "Unknown instruction: '#{instr}'"
      end
      ip = next_ip
    end
    return reg
  end

  public
  def output
    @output.pop
  end

  public
  def flush
    @output.clear
  end

  public
  def clone
    c = super
    c.instance_variable_set(:@output, Queue.new)
    return c
  end

  # Skip multiplication loops:
  #   cpy B C
  #   inc A
  #   dec C
  #   jnz C -2
  #   dec D
  #   jnz D -5
  # is equivalent to A += B * D (and C = 0, D = 0)
  MUL_SEQUENCE = [:cpy, :inc, :dec, :jnz, :dec, :jnz].freeze
  private
  def skip_mul(cpy_arg1, cpy_arg2, code, ip, reg)
    sequence = code[ip, MUL_SEQUENCE.length]
    if sequence.map(&:first) == MUL_SEQUENCE and
        sequence[3][1] == cpy_arg2 and sequence[3][2] == -2 and sequence[5][2] == -5
      target = sequence[1][1]
      r1 = cpy_arg2
      r2 = sequence[5][1]
      if [target, r1, r2].all? { |r| r.is_a? Symbol } and sequence[2][1] == r1 and sequence[4][1] == r2
        reg[target] += get(reg, cpy_arg1) * reg[r2]
        reg[r1] = 0
        reg[r2] = 0
        return ip + MUL_SEQUENCE.length
      end
    end
    return false
  end

  # Skip addition loops:
  #   inc A
  #   dec C
  #   jnz C -2
  # is equivalent to A += C (and C = 0)
  ADD_SEQUENCE = [:inc, :dec, :jnz].freeze
  private
  def skip_add(target, code, ip, reg)
    sequence = code[ip, ADD_SEQUENCE.length]
    if sequence.map(&:first) == ADD_SEQUENCE and sequence[2][2] == -2
      r1 = sequence[2][1]
      if [target, r1].all? { |r| r.is_a? Symbol } and sequence[1][1] == r1
        reg[target] += reg[r1]
        reg[r1] = 0
        return ip + ADD_SEQUENCE.length
      end
    end
    return false
  end

  private
  def reg_or_int(arg)
    if arg =~ /\A[[:lower:]]\z/
      return arg.to_sym
    elsif arg.to_i.to_s == arg
      return arg.to_i
    else
      raise "Bad argument: '#{arg}'"
    end
  end

  private
  def get(reg, arg)
    case arg
    when Symbol
      return reg[arg]
    when Numeric
      return arg
    else
      raise "Unknown argument type: #{arg.class.name}"
    end
  end

  private
  def set(reg, r, value)
    if not r.is_a?(Symbol)
      return
    end
    reg[r] = value
  end
end
