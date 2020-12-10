file = 'input'
#file = 'example1'
#file = 'example2'

input = File.read(file).strip.split("\n").map(&:to_i).sort

#part 1
diffs = []
j_out = 0
input.each do |j|
  diffs << j - j_out
  if not (1..3).include?(diffs.last)
    raise "invalid joltage difference: #{diffs.last}"
  end
  j_out = j
end
diffs << 3
puts "1-jolt differences * 3-jolt differences = #{diffs.count(1) * diffs.count(3)}"

#part 2
def num_routes_to(output, adapters, cache = {})
  if output == 0
    return 1
  elsif not cache.has_key?(output)
    i = adapters.rindex(output) - 1
    routes = 0
    while i >= 0 and output - adapters[i] <= 3
      routes += num_routes_to(adapters[i], adapters, cache)
      i -= 1
    end
    cache[output] = routes
  end
  return cache[output]
end
puts "Number of possible adapter arrangements: #{num_routes_to(input.last, [0] + input)}"
