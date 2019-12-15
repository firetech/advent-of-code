input = File.read('input').strip.split("\n")
#input = File.read('example').strip.split("\n")

def parse(input)
  bodies = []
  input.each do |line|
    if line =~ /\A<x=(-?\d+), y=(-?\d+), z=(-?\d+)>\z/
      bodies << {
        pos: {
          x: Regexp.last_match[1].to_i,
          y: Regexp.last_match[2].to_i,
          z: Regexp.last_match[3].to_i
        },
        vel: {
          x: 0,
          y: 0,
          z: 0
        }
      }
    else
      raise "Malformed line; #{line}"
    end
  end
  return bodies
end

def step(bodies)
  bodies.each do |b1|
    bodies.each do |b2|
      next if b1 == b2
      [:x, :y, :z].each do |axis|
        pos1 = b1[:pos][axis]
        pos2 = b2[:pos][axis]
        delta = if pos1 < pos2
                  1
                elsif pos1 > pos2
                  -1
                else
                  0
                end
        b1[:vel][axis] += delta
      end
    end
  end

  bodies.each do |body|
    [:x, :y, :z].each do |axis|
      body[:pos][axis] += body[:vel][axis]
    end
  end
end

# part 1
bodies = parse(input)
1000.times do |i|
  step(bodies)
end

energy = bodies.map do |b|
  pot = b[:pos].values.inject(0) { |sum, x| sum + x.abs }
  kin = b[:vel].values.inject(0) { |sum, x| sum + x.abs }
  pot * kin
end.reduce(:+)
puts "Total energy: #{energy}"

# part 2
orig = parse(input)
bodies = parse(input)
cycles = { x: nil, y: nil, z: nil }
steps = 0
while cycles.values.include? nil
  step(bodies)
  steps += 1
  cycles.each do |axis, curr|
    next if not curr.nil?
    equal = true
    bodies.zip(orig) do |body, orig|
      if body[:pos][axis] != orig[:pos][axis] or
          body[:vel][axis] != orig[:vel][axis]
        equal = false
      end
    end
    if equal
      puts "Found cycle for #{axis} axis: #{steps}"
      cycles[axis] = steps
    end
  end
end

puts "Full pattern will repeat after #{cycles.values.inject(1) { |lcm, x| lcm.lcm(x) }} cycles"


