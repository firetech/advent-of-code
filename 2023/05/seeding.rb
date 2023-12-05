require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

@seed_line, *maps = File.read(file).rstrip.split("\n\n")

@maps = {}
maps.each do |map|
  header, *lines = map.split("\n")
  if header =~ /\A(.+)-to-(.+) map:\z/
    id = [Regexp.last_match(1), Regexp.last_match(2)]
  else
    raise "Malformed map header: '#{header}'"
  end
  map = []
  @maps[id] = map
  lines.each do |line|
    case line
    when /\A(\d+) (\d+) (\d+)\z/
      dst = Regexp.last_match(1).to_i
      src = Regexp.last_match(2).to_i
      len = Regexp.last_match(3).to_i
      map << [
        (src...src+len),
        (dst...dst+len),
        dst-src
      ]
    else
      raise "Malformed map line: '#{line}'"
    end
  end
end

# Part 1
if @seed_line =~ /\Aseeds: ((?:\d+(?:\s+|\z))+)/
  seeds = Regexp.last_match(1).split(/\s+/).map(&:to_i)
else
  raise "Malformed seed line: '#{@seed_line}'"
end
results = []
seeds.each do |val|
  @maps.each do |id, map|
    map.each do |in_range, out_range, offset|
      if in_range.include?(val)
        val += offset
        break
      end
    end
  end
  results << val
end
puts "Lowest location number (listed seeds): #{results.min}"

# Part 2
if @seed_line =~ /\Aseeds: ((?:\d+\s+\d+(?:\s+|\z))+)/
  seeds2 = Regexp.last_match(1).split(/\s+/).map(&:to_i).each_slice(2).map do |src, len|
    (src...src+len)
  end
else
  raise "Malformed seed line: '#{@seed_line}'"
end
loc = 0
found = false
until found
  val = loc
  @maps.reverse_each do |id, map|
    map.each do |in_range, out_range, offset|
      if out_range.include?(val)
        val -= offset
        break
      end
    end
  end
  seeds2.each do |range|
    if range.include?(val)
      puts "Lowest location number (seed ranges): #{loc}"
      found = true
      break
    end
  end
  loc += 1
end
