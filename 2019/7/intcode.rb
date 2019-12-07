input = File.read('input').split(',').map(&:to_i)

# backport Integer.digits to Ruby <2.4
if not 1.respond_to? :digits
  class Integer
    def digits
      self.to_s.chars.map(&:to_i)
    end
  end
end

class Intcode

  def initialize(memory, verbose = true)
    @memory = memory.clone
    @verbose = verbose
    @input_buf = Queue.new
    @output_buf = Queue.new
  end

  private
  def get_param(mem, modes, addr, i)
    val = mem[addr+i]
    case modes[i]
    when 0, nil
      # read memory address
      val = mem[val]
    when 1
      # return as is
    else
      raise "Unknown param mode: #{modes[i]}"
    end
    return val
  end

  public
  def run(addr = 0)
    running = true
    mem = @memory.clone
    outputs = []
    while running
      instruction = mem[addr]
      opcode_l, opcode_h, *parmodes = instruction.digits.reverse
      opcode = (opcode_h or 0)*10 + opcode_l
      parmodes.unshift(opcode) # mainly to 1-index parmodes
      case opcode
      when 1, 2
        op1 = get_param(mem, parmodes, addr, 1)
        op2 = get_param(mem, parmodes, addr, 2)
        to = mem[addr+3]
        case opcode
        when 1
          mem[to] = op1 + op2
        when 2
          mem[to] = op1 * op2
        end
        addr += 4
      when 3
        to = mem[addr+1]
        printed = false
        if @verbose
          print "Input[#{to}]: "
        end
        i = nil
        if @input_buf.empty?
          if block_given?
            i = yield
          elsif @verbose
            i = gets.to_i
            printed = true
          end
        end
        if i.nil?
          i = @input_buf.pop
        end
        if @verbose and not printed
          puts i
        end
        mem[to] = i
        addr += 2
      when 4
        op = get_param(mem, parmodes, addr, 1)
        if @verbose
          puts "Output: #{op}"
        end
        @output_buf << op
        addr += 2
      when 5, 6
        op1 = get_param(mem, parmodes, addr, 1)
        op2 = get_param(mem, parmodes, addr, 2)
        if (opcode == 5 and op1 != 0) or
            (opcode == 6 and op1 == 0)
          addr = op2
        else
          addr += 3
        end
      when 7, 8
        op1 = get_param(mem, parmodes, addr, 1)
        op2 = get_param(mem, parmodes, addr, 2)
        to = mem[addr+3]
        case opcode
        when 7
          mem[to] = (op1 < op2) ? 1 : 0
        when 8
          mem[to] = (op1 == op2) ? 1 : 0
        end
        addr += 4
      when 99
        running = false
      else
        raise ArgumentError, "Unknown opcode #{opcode}"
      end
    end
    return mem
  end

  public
  def [](addr)
    @memory[addr]
  end

  public
  def []=(addr, val)
    @memory[addr] = val
  end

  public
  def memory
    @memory.clone
  end

  public
  def input(val)
    @input_buf << val
  end

  public
  def output
    @output_buf.pop
  end

  public
  def clear
    @input_buf.clear
    @output_buf.clear
  end

end

#part 1
amp = Intcode.new(input, false)

values = (0..4).to_a.permutation.map do |order|
  val = 0
  order.each do |phase|
    amp.input(phase)
    amp.input(val)
    amp.run
    val = amp.output
  end
  val
end

puts "Max result (0..4): #{values.max}"

#part 2
amps = 5.times.map { Intcode.new(input, false) }
in_amps = amps.clone
in_amps.unshift(in_amps.pop)
values = (5..9).to_a.permutation.map do |order|
  amps.each(&:clear)
  amps.zip(order) do |amp, phase|
    amp.input(phase)
  end
  amps.first.input(0)
  threads = []
  amps.zip(in_amps) do |amp, in_amp|
    threads << Thread.new do
      amp.run { in_amp.output }
    end
  end
  threads.each(&:join)
  amps.last.output
end

puts "Max result (5..9): #{values.max}"
