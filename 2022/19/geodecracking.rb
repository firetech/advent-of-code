file = ARGV[0] || 'input'
#file = 'example1'

@blueprints = {}
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\ABlueprint (\d+): Each ore robot costs (\d+) ore\. Each clay robot costs (\d+) ore\. Each obsidian robot costs (\d+) ore and (\d+) clay\. Each geode robot costs (\d+) ore and (\d+) obsidian\.\z/
    @blueprints[Regexp.last_match(1).to_i] = [
      Regexp.last_match(2).to_i,
      Regexp.last_match(3).to_i,
      Regexp.last_match(4).to_i, Regexp.last_match(5).to_i,
      Regexp.last_match(6).to_i, Regexp.last_match(7).to_i
    ]
  else
    raise "Malformed line: '#{line}'"
  end
end

MASK_ORE = 0b0001
MASK_CLY = 0b0010
MASK_OBS = 0b0100
MASK_GEO = 0b1000
MASK_ALL = MASK_ORE | MASK_CLY | MASK_OBS | MASK_GEO

def run(time, blueprint)
  stack = [[1,0,0,0, 0,0,0,0, MASK_ALL, time]]
  max_geo = 0
  c_ore_ore, c_cly_ore, c_obs_ore, c_obs_cly, c_geo_ore, c_geo_obs = blueprint
  max_c_ore = [c_ore_ore, c_cly_ore, c_obs_ore, c_geo_ore].max
  until stack.empty?
    r_ore, r_cly, r_obs, r_geo, ore, cly, obs, geo, mask, time = stack.pop

    max_geo = geo if geo > max_geo
    next if time == 0
    # If we can't beat the current best even by producing one geode robot per
    # minute from now, no need to continue
    next if geo + time*r_geo + time*(time-1)/2 <= max_geo

    new_ore = ore + r_ore
    new_cly = cly + r_cly
    new_obs = obs + r_obs
    new_geo = geo + r_geo
    new_mask = mask
    new_time = time - 1
    if mask & MASK_GEO != 0 and ore >= c_geo_ore and obs >= c_geo_obs
      # Build geode robot
      stack << [r_ore, r_cly, r_obs, r_geo+1,
                new_ore-c_geo_ore, new_cly, new_obs-c_geo_obs, new_geo,
                MASK_ALL, new_time]
      new_mask &= ~MASK_GEO
    end
    if mask & MASK_OBS != 0 and r_obs < c_geo_obs and
        ore >= c_obs_ore and cly >= c_obs_cly
      # Build obsidian robot
      stack << [r_ore, r_cly, r_obs+1, r_geo,
                new_ore-c_obs_ore, new_cly-c_obs_cly, new_obs, new_geo,
                MASK_ALL, new_time]
      new_mask &= ~MASK_OBS
    end
    if mask & MASK_CLY != 0 and r_cly < c_obs_cly and ore >= c_cly_ore
      # Build clay robot
      stack << [r_ore, r_cly+1, r_obs, r_geo,
                new_ore-c_cly_ore, new_cly, new_obs, new_geo,
                MASK_ALL, new_time]
      new_mask &= ~MASK_CLY
    end
    if mask & MASK_ORE != 0 and r_ore < max_c_ore and ore >= c_ore_ore
      # Build ore robot
      stack << [r_ore+1, r_cly, r_obs, r_geo,
                new_ore-c_ore_ore, new_cly, new_obs, new_geo,
                MASK_ALL, new_time]
      new_mask &= ~MASK_ORE
    end

    if ore < max_c_ore or new_mask == mask
      # If we don't have ores needed for all types (or can't build), try waiting
      # (Always build a robot if we have the max needed ores)
      stack << [r_ore, r_cly, r_obs, r_geo,
                new_ore, new_cly, new_obs, new_geo,
                new_mask, new_time]
    end
  end
  return max_geo
end

# Part 1
quality = 0
@blueprints.each do |id, blueprint|
  quality += id * run(24, blueprint)
end
puts "Sum of quality levels: #{quality}"

# Part 2
product = 1
@blueprints.each do |id, blueprint|
  product *= run(32, blueprint) if id <= 3
end
puts "Product of first three blueprints: #{product}"
