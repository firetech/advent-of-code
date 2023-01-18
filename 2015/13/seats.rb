require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip.split("\n")
#input = File.read('example').strip.split("\n")

#part 1
@hapmap = {}
factor = { 'gain' => 1, 'lose' => -1 }
input.each do |line|
  if line =~ /\A(\w+) would (gain|lose) (\d+) happiness units by sitting next to (\w+)\.\z/
    @hapmap[Regexp.last_match[1]] ||= {}
    @hapmap[Regexp.last_match[1]][Regexp.last_match[4]] = Regexp.last_match[3].to_i * factor[Regexp.last_match[2]]
  else
    raise "Malformed line: #{line}"
  end
end

=begin
# too slow...
@seatings = []
seating_check = []
@hapmap.keys.permutation.each do |seating|
  if seating_check.include?(seating)
    next
  end
  @seatings << seating
  (seating * 2).each_cons(seating.length) do |equal|
    seating_check << equal
  end
end
=end

@seatings = @hapmap.keys.permutation

def best_seating
  totals = @seatings.map do |seating|
    sum = 0
    (seating + [seating.first]).each_cons(2) do |a,b|
      sum += (@hapmap[a][b] || 0) + (@hapmap[b][a] || 0)
    end
    sum
  end.sort

  return totals.last
end

puts "Best combination: #{best_seating}"

#part 2
@hapmap['Me'] = {}
puts "Best combination incl Me: #{best_seating}"
