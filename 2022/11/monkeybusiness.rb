require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

class Monkey
  attr_reader :inspected, :div

  def initialize(lines)
    @next = {}
    lines.each do |line|
      case line
      when /\A  Starting items: (\d+(?:, \d+)*)\z/
        @start_items = Regexp.last_match(1).split(', ').map(&:to_i)
      when /\A  Operation: new = old ([+*]) (old|\d+)\z/
        if Regexp.last_match(1) == '*' and Regexp.last_match(2) == 'old'
          @op = [:**, 2]
        elsif Regexp.last_match(2) != 'old'
          @op = [Regexp.last_match(1).to_sym, Regexp.last_match(2).to_i]
        else
          raise "Malformed line: '#{line}'"
        end
      when /\A  Test: divisible by (\d+)\z/
        @div = Regexp.last_match(1).to_i
      when /\A    If (true|false): throw to monkey (\d+)\z/
        @next[Regexp.last_match(1) == 'true'] = Regexp.last_match(2).to_i
      else
        raise "Malformed line: '#{line}'"
      end
    end
    reset
  end

  def reset
    @inspected = 0
    @items = @start_items.clone
  end

  def run(div_by_3 = true)
    throws = []
    @items.each do |level|
      level = level.send(*@op)
      level /= 3 if div_by_3  # Part 1
      throws << [level, @next[level % @div == 0]]
      @inspected += 1
    end
    @items = []
    return throws
  end

  def <<(item)
    @items << item
  end
end

@monkeys = {}
File.read(file).rstrip.split("\n\n").each do |block|
  lines = block.split("\n")
  title = lines.shift
  case title
  when /\AMonkey (\d+):\z/
    @monkeys[Regexp.last_match(1).to_i] = Monkey.new(lines)
  else
    raise "Malformed line: '#{title}'"
  end
end

# Keep numbers manageable by running mod [the LCM of all divisors].
@lcm = @monkeys.values.map(&:div).inject(&:lcm)

def round(div_by_3)
  @monkeys.each do |id, monkey|
    monkey.run(div_by_3).each do |item, to|
      @monkeys[to] << item % @lcm
    end
  end
end

def monkey_business
  @monkeys.values.map(&:inspected).sort.last(2).inject(&:*)
end

# Part 1
20.times { round(true) }
puts "Monkey business after 20 rounds: #{monkey_business}"

# Part 2
@monkeys.each_value(&:reset)
10000.times { round(false) }
puts "Monkey business after 10000 rounds: #{monkey_business}"
