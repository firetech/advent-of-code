require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

seed_line, *maps = File.read(file).rstrip.split("\n\n")
if seed_line =~ /\Aseeds: ((?:\d+(?:\s+|\z))+)/
  @seeds = Regexp.last_match(1).split(/\s+/).map(&:to_i)
else
  raise "Malformed seed line: '#{@seed_line}'"
end

@maps = []
maps.each do |map|
  header, *lines = map.split("\n")
  if header =~ /\A(.+)-to-(.+) map:\z/
    id = [Regexp.last_match(1), Regexp.last_match(2)]
  else
    raise "Malformed map header: '#{header}'"
  end
  map = []
  @maps << map
  lines.each do |line|
    case line
    when /\A(\d+) (\d+) (\d+)\z/
      dst = Regexp.last_match(1).to_i
      src = Regexp.last_match(2).to_i
      len = Regexp.last_match(3).to_i
      map << [
        (src...src+len),
        dst-src
      ]
    else
      raise "Malformed map line: '#{line}'"
    end
  end
end

# Part 1
results = []
@seeds.each do |val|
  @maps.each do |map|
    map.each do |range, offset|
      if range.include?(val)
        val += offset
        break
      end
    end
  end
  results << val
end
puts "Lowest location number (listed seeds): #{results.min}"

# Part 2
@seed_ranges = @seeds.each_slice(2).map do |src, len|
  src...(src+len)
end

# Map to possible ranges through each conversion.
output_ranges = @maps.inject(@seed_ranges) do |ranges, map|
  ranges.flat_map do |src|
    # Find intersections with map ranges.
    intersections = map.filter_map do |m_range, m_offset|
      next if src.max < m_range.min or m_range.max < src.min
      int = [src.min, m_range.min].max..[src.max, m_range.max].min
      [int, (int.min + m_offset)..(int.max + m_offset)]
    end

    # Generate list of possible output ranges from the input ranges.
    dst = []
    min = src.min
    intersections.sort_by { |f, t| f.min }.each do |from, to|
      if min < from.min
        # Input outside mapping range, keep that part of the range as is.
        dst << (min...from.min)
      end
      dst << to
      min = from.max + 1
    end
    # Input after last mapping range
    dst << (min..src.max) if src.max > min
    dst
  end
end
min_output = output_ranges.min_by(&:min).min
puts "Lowest location number (seed ranges): #{min_output}"
