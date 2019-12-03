input = File.read('input').strip.split("\n")
#input = File.read('example').strip.split("\n")

#part 1
@reindeer = {}
input.each do |line|
  if line =~ /\A(\w+) can fly (\d+) km\/s for (\d+) seconds, but then must rest for (\d+) seconds\.\z/
    @reindeer[Regexp.last_match[1]] = {
      speed: Regexp.last_match[2].to_i,
      move_time: Regexp.last_match[3].to_i,
      rest_time: Regexp.last_match[4].to_i,
      lead_time: 0 #for part 2
    }
  else
    raise "Malformed line: #{line}"
  end
end

target = 2503
#target = 1000

def find_winner(target)
  distances = @reindeer.map do |name, data|
    remaining = target
    distance = 0
    while remaining > 0
      move_time = [data[:move_time], remaining].min
      distance += data[:speed] * move_time
      remaining -= move_time
      remaining -= data[:rest_time]
    end
    [name, distance]
  end.sort_by { |name, distance| distance }.reverse
  winner, winner_pos = distances.first
  return distances.select { |name, distance| distance == winner_pos }
end

puts 'Winning reindeer (%s) traveled %d km' % find_winner(target).first

#part 2
(1..target).each do |t|
  find_winner(t).each do |leader, distance|
    @reindeer[leader][:lead_time] += 1
  end
end

winner, data = @reindeer.max_by { |name, data| data[:lead_time] }
puts 'Winning reindeer (%s) got %d points' % [ winner, data[:lead_time]]
