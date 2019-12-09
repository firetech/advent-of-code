input = File.read('input').split(',').map(&:to_i)

require_relative '../lib/intcode'

# part 1
i = Intcode.new(input)
i[1] = 12
i[2] = 2
i.run
puts "1202 output: #{i[0]}"


#part 2
(0...100).each do |noun|
  (0...100).each do |verb|
    i.reset
    i[1] = noun
    i[2] = verb
    i.run
    if i[0] == 19690720
      puts "19690720 input: #{noun}#{verb}"
      break
    end
  end
end
