input = 33100000

LIMIT = 1000000

#part 1
elf_sum = input / 10
houses = Array.new(LIMIT, 1)
2.upto(LIMIT) do |elf|
  elf.step(LIMIT, elf) do |house|
    houses[house-1] += elf
  end
end
puts "House ##{houses.index { |sum| sum >= elf_sum } + 1} gets >= #{input} presents in infinite mode"

#part 2
houses = Array.new(LIMIT, 0)
1.upto(LIMIT) do |elf|
  house = elf
  50.times do
    houses[house-1] += elf * 11
    house += elf
    if house > LIMIT
      break
    end
  end
end
puts "House ##{houses.index { |sum| sum >= input } + 1} gets >= #{input} presents in 50 house mode"

