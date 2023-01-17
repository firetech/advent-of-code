require_relative '../../lib/aoc_api'

input = ARGV[0] || AOC.input()
#input = 'flqrgnkx'

# Part 1
@grid = []
128.times do |y|
  # Adapted from day 10
  current = 0
  skip = 0
  list = (0..255).to_a
  lengths = "#{input}-#{y}".bytes + [17, 31, 73, 47, 23]

  64.times do
    lengths.each do |length|
      list[0, length] = list[0, length].reverse
      list.rotate!(length + skip)
      current = (current + length + skip) % list.length
      skip += 1
    end
  end

  list.rotate!(-current)
  parts = list.each_slice(16).map { |s| s.inject(&:^) }

  @grid << parts.map { |p| ('%08b' % p).chars.map { |b| b == '1' } }.flatten
end

puts "#{@grid.flatten.count(true)} squares used"


# Part 2
@group = Array.new(128) { Array.new(128, nil) }

group = 0
@grid.each_with_index do |row, y|
  row.each_with_index do |cell, x|
    if cell and @group[y][x].nil?
      group += 1
      # I love the smell of BFS in the morning :P
      queue = [[x, y]]
      while not queue.empty?
        qx, qy = queue.shift
        [[0, -1], [-1, 0], [1, 0], [0, 1]].each do |dx, dy|
          px, py = qx+dx, qy+dy
          if (0...128).include?(px) and (0...128).include?(py) and @grid[py][px]
            if @group[py][px].nil?
              @group[py][px] = group
              queue << [px, py]
            elsif @group[py][px] != group
              raise "Colliding groups, this shouldn't happen..."
            end
          end
        end
      end
    end
  end
end

puts "#{group} groups found"
