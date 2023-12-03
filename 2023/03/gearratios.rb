require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@map = File.read(file).rstrip.split("\n")
@height = @map.length
@width = @map.first.length

def check_symbol(c)
  case c
  when '.', /\d/
    return false, false
  when '*'
    return true, true
  else
    return true, false
  end
end

part_sum = 0 # Part 1
@gears = {} # Part 2
@map.each_with_index do |line, y|
  offset = 0
  until (x = line.index(/(\d+)/, offset)).nil?
    n_str = Regexp.last_match(1)
    n_length = n_str.length
    n = n_str.to_i
    adjacent = false
    gear = nil
    if y > 0
      ([0, x-1].max..[x+n_length, @width-1].min).each do |xx|
        is_symbol, is_gear = check_symbol(@map[y-1][xx])
        adjacent ||= is_symbol
        if is_gear
          raise unless gear.nil?
          gear = [xx, y-1]
        end
      end
    end
    if x > 0
      is_symbol, is_gear = check_symbol(@map[y][x-1])
      adjacent ||= is_symbol
      if is_gear
        raise unless gear.nil?
        gear = [x-1, y]
      end
    end
    if x+n_length < @width
      is_symbol, is_gear = check_symbol(@map[y][x+n_length])
      adjacent ||= is_symbol
      if is_gear
        raise unless gear.nil?
        gear = [x+n_length, y]
      end
    end
    if y < @height - 1
      ([0, x-1].max..[x+n_length, @width-1].min).each do |xx|
        is_symbol, is_gear = check_symbol(@map[y+1][xx])
        adjacent ||= is_symbol
        if is_gear
          raise unless gear.nil?
          gear = [xx, y+1]
        end
      end
    end
    part_sum += n if adjacent
    unless gear.nil?
      @gears[gear] ||= []
      @gears[gear] << n
    end
    offset = x+n_length
  end
end

# Part 1
puts "Sum of all part numbers: #{part_sum}"

# Part 2
gear_sum = 0
@gears.each do |pos, parts|
  next if parts.length < 2
  raise if parts.length > 2
  gear_sum += parts.inject(:*)
end
puts "Sum of all gear ratios: #{gear_sum}"
