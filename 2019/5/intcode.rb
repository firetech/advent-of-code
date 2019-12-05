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

  def input(val)
    @input_buf << val
  end

  def run(addr = 0)
    running = true
    mem = @memory.clone
    while running
      instruction = mem[addr]
      opcode_l, opcode_h, *parmodes = instruction.digits.reverse
      opcode = (opcode_h or 0)*10 + opcode_l
      parmodes.unshift(-1) # 1-index parmodes
      case opcode
      when 1
        parmodes[3] = 1 # force 'immediate' mode (used as address for writing later)
        op1 = get_param(mem, parmodes, addr, 1)
        op2 = get_param(mem, parmodes, addr, 2)
        res = get_param(mem, parmodes, addr, 3)
        mem[res] = op1 + op2
        addr += 4
      when 2
        parmodes[3] = 1 # force 'immediate' mode (used as address for writing later)
        op1 = get_param(mem, parmodes, addr, 1)
        op2 = get_param(mem, parmodes, addr, 2)
        res = get_param(mem, parmodes, addr, 3)
        mem[res] = op1 * op2
        addr += 4
      when 3
        parmodes[1] = 1 # force 'immediate' mode (used as address for writing later)
        op = get_param(mem, parmodes, addr, 1)
        print "Input[#{op}]: "
        if @input_buf.empty?
          i = gets.to_i
        else
          i = @input_buf.shift
          pp i
        end
        mem[op] = i
        addr += 2
      when 4
        op = get_param(mem, parmodes, addr, 1)
        puts "Output[#{op}]: #{op}"
        addr += 2
      # For part 2
      when 5
        op1 = get_param(mem, parmodes, addr, 1)
        op2 = get_param(mem, parmodes, addr, 2)
        if op1 != 0
          addr = op2
        else
          addr += 3
        end
      # For part 2
      when 6
        op1 = get_param(mem, parmodes, addr, 1)
        op2 = get_param(mem, parmodes, addr, 2)
        if op1 == 0
          addr = op2
        else
          addr += 3
        end
      # For part 2
      when 7
        parmodes[3] = 1 # force 'immediate' mode (used as address for writing later)
        op1 = get_param(mem, parmodes, addr, 1)
        op2 = get_param(mem, parmodes, addr, 2)
        res = get_param(mem, parmodes, addr, 3)
        mem[res] = (op1 < op2) ? 1 : 0
        addr += 4
      # For part 2
      when 8
        parmodes[3] = 1 # force 'immediate' mode (used as address for writing later)
        op1 = get_param(mem, parmodes, addr, 1)
        op2 = get_param(mem, parmodes, addr, 2)
        res = get_param(mem, parmodes, addr, 3)
        mem[res] = (op1 == op2) ? 1 : 0
        addr += 4
      when 99
        running = false
      else
        raise ArgumentError, "Unknown opcode #{opcode}"
      end
    end
    return mem
  end

  def [](addr)
    @memory[addr]
  end

  def []=(addr, val)
    @memory[addr] = val
  end

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
i = Intcode.new(input)
i.input 5
i.run
