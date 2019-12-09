input = File.read('input').split(',').map(&:to_i)

# part 1
class Intcode

  def initialize(memory)
    @memory = memory.clone
  end


  def run(addr = 0)
    running = true
    mem = @memory.clone
    while running
      opcode = mem[addr]
      case opcode
      when 1
        op1 = mem[mem[addr+1]]
        op2 = mem[mem[addr+2]]
        res = mem[addr+3]
        mem[res] = op1 + op2
        addr += 4
      when 2
        op1 = mem[mem[addr+1]]
        op2 = mem[mem[addr+2]]
        res = mem[addr+3]
        mem[res] = op1 * op2
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

i = Intcode.new(input)
i[1] = 12
i[2] = 2
puts "1202 output: #{i.run[0]}"


#part 2
(0...100).each do |noun|
  (0...100).each do |verb|
    i[1] = noun
    i[2] = verb
    if i.run[0] == 19690720
      puts "19690720 input: #{noun}#{verb}"
      break
    end
  end
end
