@input = File.read('input').strip.split("\n").map(&:to_i)

def find2020(count)
  @input.combination(count) do |c|
    if c.inject(0) { |sum, x| sum + x } == 2020
      puts "#{c.join(' + ')} = 2020, #{c.join(' * ')} = #{c.inject(1) { |prod, x| prod * x }}"
      break
    end
  end
end

#part 1
find2020(2)

#part 2
find2020(3)
