require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

DAYS = [
  80, # Part 1
  256 # Part 2
]

fish = Hash.new(0)
File.read(file).strip.split(',').map(&:to_i).each { |f| fish[f] += 1 }
@fish = [fish]

DAYS.max.times do
  new_fish = @fish.last.transform_keys { |f| f - 1 }
  n_new = new_fish.delete(-1)
  unless n_new.nil?
    new_fish[6] = (new_fish[6] or 0) + n_new
    new_fish[8] = n_new
  end
  @fish << new_fish
end

DAYS.each do |days|
  puts "Lanternfish after #{days} days: #{@fish[days].values.sum}"
end
