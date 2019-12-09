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

  def initialize(memory)
    @memory = memory.clone
    @input_buf = []
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
  def input(val)
    @input_buf << val
  end

  public
  def run(addr = 0)
    running = true
    mem = @memory.clone
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
        print "Input[#{to}]: "
        if @input_buf.empty?
          i = gets.to_i
        else
          i = @input_buf.shift
          puts i
        end
        mem[to] = i
        addr += 2
      when 4
        op = get_param(mem, parmodes, addr, 1)
        puts "Output: #{op}"
        addr += 2
      # For part 2
      when 5, 6
        op1 = get_param(mem, parmodes, addr, 1)
        op2 = get_param(mem, parmodes, addr, 2)
        if (opcode == 5 and op1 != 0) or
            (opcode == 6 and op1 == 0)
          addr = op2
        else
          addr += 3
        end
      # For part 2
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

end

puts "Part 1:"
i = Intcode.new(input)
i.input 1
i.run

puts
puts "Part 2:"
i.input 5
i.run
