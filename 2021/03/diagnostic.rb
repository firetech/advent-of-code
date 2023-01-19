require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@length = nil
@inputs = []
File.read(file).strip.split("\n").each do |line|
  case line
  when /\A[0-1]+\z/
    if @length.nil?
      @length = line.length
    elsif line.length != @length
      raise "Mismatching length: #{line.length} != #{@length}"
    end
    @inputs << line.to_i(2)
  else
    raise "Malformed line: '#{line}'"
  end
end

def pos_val(val, pos)
  bit_pos = @length - 1 - pos
  return (val & 1 << bit_pos) >> bit_pos
end

def pos_count(pos, inputs = @inputs)
  count = Hash.new(0)
  inputs.each do |val|
    count[pos_val(val, pos)] += 1
  end
  max_val = count.keys.max_by { |b| count[b] }
  min_val = count.keys.min_by { |b| count[b] }
  return max_val, min_val
end

gamma = 0
epsilon = 0
oxygen_inputs = @inputs
co2_inputs = @inputs
@length.times do |pos|
  # Part 1
  max_val, min_val = pos_count(pos, @inputs)
  gamma = gamma << 1 | max_val
  epsilon = epsilon << 1 | min_val

  # Part 2
  if oxygen_inputs.length > 1
    oxygen_max, oxygen_min = pos_count(pos, oxygen_inputs)
    oxygen_val = oxygen_max == oxygen_min ? 1 : oxygen_max
    oxygen_inputs = oxygen_inputs.select do |val|
      pos_val(val, pos) == oxygen_val
    end
  end
  if co2_inputs.length > 1
    co2_max, co2_min = pos_count(pos, co2_inputs)
    co2_val = co2_max == co2_min ? 0 : co2_min
    co2_inputs = co2_inputs.select do |val|
      pos_val(val, pos) == co2_val
    end
  end
end

# Part 1
puts "Power consumption: #{gamma} * #{epsilon} = #{gamma * epsilon}"

# Part 2
oxygen = oxygen_inputs.first
co2 = co2_inputs.first
puts "Life support rating: #{oxygen} * #{co2} = #{oxygen * co2}"
