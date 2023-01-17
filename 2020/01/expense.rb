require_relative '../../lib/aoc_api'

@input = File.read(ARGV[0] || AOC.input_file()).strip.split("\n").map(&:to_i)

def find2020(count)
  @input.combination(count) do |c|
    if c.sum == 2020
      puts "#{c.join(' + ')} = 2020, #{c.join(' * ')} = #{c.inject(&:*)}"
      break
    end
  end
end

#part 1
find2020(2)

#part 2
find2020(3)
