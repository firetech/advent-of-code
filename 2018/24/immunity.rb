require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

class BattleGroup
  attr_reader :count, :hp, :attack, :attack_type, :initiative

  def initialize(count, hp, mods, attack, attack_type, initiative)
    @count = count
    @hp = hp
    @weak = Set.new(mods[:weak])
    @immune = Set.new(mods[:immune])
    @attack = attack
    @attack_type = attack_type
    @initiative = initiative
  end

  def boost(value)
    @attack += value
  end

  def power
    @count * @attack
  end

  # Comparison for target selection sorting
  # Order of decreasing power, with decreasing initiative as tie-breaker
  def <=>(other)
    power_cmp = other.power <=> self.power
    if power_cmp == 0
      return other.initiative <=> @initiative
    end
    return power_cmp
  end

  def immune_to?(type)
    @immune.include?(type)
  end

  def weak_to?(type)
    @weak.include?(type)
  end

  def potential_damage_to(target)
    if target.immune_to?(@attack_type)
      0
    elsif target.weak_to?(@attack_type)
      power * 2
    else
      power
    end
  end

  def attack(target)
    return if @count <= 0
    damage = potential_damage_to(target)
    killed = [damage / target.hp, target.count].min
    target.count -= killed
    return killed
  end

  protected
  attr_writer :count
end


@armies = {}
army = nil
File.read(file).strip.split("\n").each do |line|
  case line
  when 'Immune System:'
    army = :host
    @armies[army] = []
  when 'Infection:'
    army = :infection
    @armies[army] = []
  when /\A(\d+) units each with (\d+) hit points(?: \((.+)\))? with an attack that does (\d+) (\w+) damage at initiative (\d+)\z/
    count = Regexp.last_match(1).to_i
    hp = Regexp.last_match(2).to_i
    mods_str = Regexp.last_match(3)
    attack = Regexp.last_match(4).to_i
    attack_type = Regexp.last_match(5).to_sym
    initiative = Regexp.last_match(6).to_i
    mods = {}
    unless mods_str.nil?
      mods_str.split('; ').each do |mod|
        case mod
        when /\A(immune|weak) to ([\w ,]+)\z/
          mod_type = Regexp.last_match(1).to_sym
          mods[mod_type] = Regexp.last_match(2).split(', ').map(&:to_sym)
        else
          raise "Malformed modifier: '#{str}'"
        end
      end
    end
    @armies[army] << BattleGroup.new(
      count,
      hp,
      mods,
      attack,
      attack_type,
      initiative
    )
  when ''
    # Ignore
  else
    raise "Malformed line: '#{line}'"
  end
end

def fight(boost = 0)
  armies = @armies.transform_values { |groups| groups.map(&:clone) }
  armies[:host].each { |g| g.boost(boost) }
  i = 0
  while armies.values.count(&:empty?) < armies.count - 1
    # Target selection
    targets = {}
    armies.each do |team, groups|
      enemy_groups = Set.new((armies.keys - [team]).flat_map { |t| armies[t] })
      groups.sort.each do |group|
        list = enemy_groups.group_by { |g| group.potential_damage_to(g) }
        max_damage = list.keys.max
        next if max_damage == 0 or max_damage.nil?
        target = list[max_damage].min # == .sort.first
        enemy_groups.delete(target)
        targets[group] = target
      end
    end

    # Attacking
    killed = targets.sort_by { |a, t| - a.initiative }.map do |attacker, target|
      attacker.attack(target)
    end
    if killed.all? { |k| k == 0 }
      total_units = 0
      units_str = armies.map do |team, groups|
        count = groups.map(&:count).sum
        total_units += count
        "#{team.to_s.capitalize} has #{count} units"
      end
      puts "Infinite battle, #{units_str.join(', ')}."
      return nil, total_units
    end


    # Weed out the dead
    armies.transform_values! { |groups| groups.select { |g| g.count > 0 } }

    i += 1
  end
  winner, groups = armies.reject { |team, groups| groups.empty? }.first
  units_left = groups.map(&:count).sum
  puts "#{winner.to_s.capitalize} won, with #{units_left} units left."
  return winner, units_left
end

# Part 1
print "Base fight: "
fight

# Part 2
puts
strongest_infection = @armies[:infection].max_by do |group|
  group.count * group.hp
end
weakest_host = @armies[:host].min_by do |group|
  group.potential_damage_to(strongest_infection)
end
current_damage = weakest_host.potential_damage_to(strongest_infection)
wipeout_damage = strongest_infection.count * strongest_infection.hp
max_boost = (wipeout_damage - current_damage) / weakest_host.count
puts "Maximum boost with relevance: #{max_boost}"
puts 'Searching for minimum boost for victory...'
units = {}
min_boost = (1..max_boost).bsearch do |boost|
  print "Boost #{boost}: "
  winner, units_left = fight(boost)
  units[boost] = units_left
  winner == :host
end
puts
puts "Minimum boost for victory: #{min_boost}, units left: #{units[min_boost]}"
