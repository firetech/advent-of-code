require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file(); @part2_emptiness = (ARGV[1] || 1_000_000).to_i
#file = 'example1'; @part2_emptiness = 10

@galaxies = []
@map = File.read(file).rstrip.split("\n").map.with_index do |line, y|
  x = 0
  until (x = line.index('#', x)).nil?
    @galaxies << [x, y]
    x += 1
  end
  line.chars
end

def find_empty(lines)
  empty = []
  lines.each_with_index do |line, i|
    if line.all?('.')
      empty << i
    end
  end
  return empty
end

@empty_y = find_empty(@map)
@empty_x = find_empty(@map.transpose)

sum1 = 0 # Part 1
sum2 = 0 # Part 2
@galaxies.combination(2) do |(x1, y1), (x2, y2)|
  xs = [x1, x2].sort
  ys = [y1, y2].sort

  dist = (xs[1] - xs[0]) + (ys[1] - ys[0])
  empty_dist = @empty_x.count { |x| x.between?(xs[0], xs[1]) } +
               @empty_y.count { |y| y.between?(ys[0], ys[1]) }

  sum1 += dist + empty_dist # Part 1
  sum2 += dist + (@part2_emptiness-1) * empty_dist # Part 2
end

# Part 1
puts "Sum of distances between galaxies: #{sum1}"

# Part 2
puts "Sum of distances between galaxies (emptiness #{@part2_emptiness}): #{sum2}"
