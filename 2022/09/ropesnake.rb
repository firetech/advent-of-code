require 'set'

file = ARGV[0] || 'input'
#file = 'example1'
#file = 'example2'

def move_tail(head_pos, tail_pos)
  tail_delta = head_pos.zip(tail_pos).map { |h, t| (h - t).abs }
  if tail_delta.any? { |d| d > 1 }
    # Move tail
    if head_pos.zip(tail_pos).any? { |h, t| h == t }
      # ...straight
      tail_pos = tail_pos.zip(head_pos).map { |t, h| h + (t <=> h) }
    else
      # ...diagonally
      possible = []
      positions = [[-1, -1], [-1, 1], [1, 1], [1, -1]].map do |delta|
        pos = tail_pos.zip(delta).map { |t, d| t + d }
        dist = head_pos.zip(pos).map { |h, p| (h - p).abs }
        if dist.all? { |d| d <= 1 }
          possible << pos
        end
      end
      if possible.length > 1
        raise "Multiple possible diagonal moves"
      end
      tail_pos = possible.first
    end
  end
  return tail_pos
end

DIRS = {
  'L' => [-1, 0],
  'R' => [1, 0],
  'U' => [0, -1],
  'D' => [0, 1],
}

head_pos = [0, 0]
tail_pos = [[0, 0]] * 9 # Since we overwrite, duplication is not an issue
@visited1 = Set[tail_pos.first] # Part 1
@visited2 = Set[tail_pos.last] # Part 2
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A([LRUD]) (\d+)\z/
    delta = DIRS[Regexp.last_match(1)]
    dist = Regexp.last_match(2).to_i
    dist.times do
      head_pos = head_pos.zip(delta).map { |p, dp| p + dp }
      last_head = head_pos
      tail_pos = tail_pos.map do |tp|
        new_tp = move_tail(last_head, tp)
        last_head = new_tp
      end
      @visited1 << tail_pos.first
      @visited2 << tail_pos.last
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

puts "First tail visited #{@visited1.length} positions"
puts "Last tail visited #{@visited2.length} positions"
