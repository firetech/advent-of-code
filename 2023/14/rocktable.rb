require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

PART2_CYCLES = 1_000_000_000

@map = File.read(file).rstrip.split("\n").map(&:chars)

def total_load(map)
  sum = 0
  map.reverse_each.with_index do |line, i|
    sum += line.count('O') * (i + 1)
  end
  return sum
end

map = @map
seen = {}
load_after = {}
PART2_CYCLES.times do |cycle|
  4.times do |dir|
    case dir
    when 0
      calc_map = map.transpose
    when 1
      calc_map = map
    when 2
      calc_map = map.transpose.map(&:reverse)
    when 3
      calc_map = map.map(&:reverse)
    end
    new_map = []
    calc_map.each do |line|
      rolling = line.each_index.select { |i| line[i] == 'O' }
      stops = line.each_index.select { |i| line[i] == '#' }
      top = 0
      new_line = line.clone
      rolling.each do |r|
        blockers = stops.select { |s| s < r and s >= top}
        top = (blockers.max + 1) unless blockers.empty?
        if r != top
          new_line[r] = '.'
          new_line[top] = 'O'
        end
        top += 1
      end
      new_map << new_line
    end
    case dir
    when 0
      map = new_map.transpose
    when 1
      map = new_map
    when 2
      map = new_map.map(&:reverse).transpose
    when 3
      map = new_map.map(&:reverse)
    end
    if cycle == 0 and dir == 0
      puts "Total north load after tilting north: #{total_load(map)}"
    end
  end
  hash = map.hash
  unless (last_cycle = seen[hash]).nil?
    cycle_len = cycle - last_cycle
    missing = PART2_CYCLES - cycle
    puts "Total north load after #{PART2_CYCLES} cycles: #{load_after[last_cycle + (missing % cycle_len)]}"
    break
  else
    seen[hash] = cycle
  end
  load_after[cycle + 1] = total_load(map)
end
