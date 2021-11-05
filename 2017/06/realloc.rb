input = File.read('input').strip
#input = '0 2 7 0'

banks = input.split(/\s+/).map(&:to_i)

seen = {}
cycles = 0

while not seen.include?(banks)
  seen[banks.clone] = cycles

  realloc = 0
  index = 0
  banks.each_with_index do |bank, i|
    if bank > realloc
      realloc = bank
      index = i
    end
  end

  banks[index] = 0
  while realloc > 0
    index = (index + 1) % banks.length
    banks[index] += 1
    realloc -= 1
  end

  cycles += 1
end

# Part 1
puts "Cycles until seen state: #{cycles}"

# Part 2
puts "Loop size: #{cycles - seen[banks]}"
