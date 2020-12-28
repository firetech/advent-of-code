require_relative '../lib/assembunny'

file = 'input'; inputs = [7, 12]
#file = 'example1'; inputs = [0]

assembunny = AssemBunny.new(file)

inputs.each do |eggs|
  puts "Value to safe (input #{eggs}): #{assembunny.run(a: eggs)[:a]}"
end
