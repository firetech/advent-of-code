require '../../lib/multicore'

file = ARGV[0] || 'input'
#file = 'example1'

@blueprints = {}
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\ABlueprint (\d+): Each ore robot costs (\d+) ore\. Each clay robot costs (\d+) ore\. Each obsidian robot costs (\d+) ore and (\d+) clay\. Each geode robot costs (\d+) ore and (\d+) obsidian\.\z/
    @blueprints[Regexp.last_match(1).to_i] = [
      [Regexp.last_match(2).to_i, 0, 0, 0],
      [Regexp.last_match(3).to_i, 0, 0, 0],
      [Regexp.last_match(4).to_i, Regexp.last_match(5).to_i, 0, 0],
      [Regexp.last_match(6).to_i, 0, Regexp.last_match(7).to_i, 0]
    ]
  else
    raise "Malformed line: '#{line}'"
  end
end

def run(blueprint, time, robots = [1, 0, 0, 0], materials = [0, 0, 0, 0],
        cache = {})
  return materials.last if time == 0

  cache[[time, robots, materials].hash] ||= begin
    possibilities = []
    if materials.first < blueprint.map(&:first).max
      possibilities << -1
    end
    blueprint.each_with_index do |costs, r|
      if costs.each_with_index.all? { |amount, m| materials[m] >= amount } and
          (r == 3 or blueprint.any? { |c| c[r] > robots[r] })
        possibilities << r
      end
    end
    if possibilities.include?(3)
      possibilities = [3]
    end
    max_geodes = 0
    possibilities.each do |build|
      if build == -1
        cost = []
        new_robots = robots
      else
        cost = blueprint[build]
        new_robots = robots.clone
        new_robots[build] += 1
      end
      new_materials = materials.map.with_index do |amount, m|
        amount + robots[m] - (cost[m] or 0)
      end
      geodes = run(blueprint, time - 1, new_robots, new_materials, cache)
      max_geodes = geodes if geodes > max_geodes
    end

    max_geodes
  end
end

quality = 0
product = 1
stop = nil
begin
  input, output, stop = Multicore.run do |worker_in, worker_out|
    loop do
      part, id, blueprint, time = worker_in[]
      worker_out[[part, id, run(blueprint, time)]]
    end
  end
  @blueprints.each do |id, blueprint|
    # Part 1
    input << [1, id, blueprint, 24]

    # Part 2
    if id <= 3
      input << [2, id, blueprint, 32]
    end
  end
  (@blueprints.length + 3).times do
    part, id, geodes = output.pop
    case part
    when 1
      # Part 1
      quality += id * geodes
    when 2
      # Part 2
      product *= geodes
    end
  end
ensure
  stop[] unless stop.nil?
end

# Part 1
puts "Sum of quality levels: #{quality}"

# Part 2
puts "Product of first three blueprints: #{product}"
