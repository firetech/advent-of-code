require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
@player_hp = (ARGV[1] || 50).to_i
@player_mana = (ARGV[2] || 500).to_i

File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\AHit Points: (\d+)\z/
    @boss_hp = Regexp.last_match(1).to_i
  when /\ADamage: (\d+)\z/
    @boss_atk = Regexp.last_match(1).to_i
  else
    raise "Malformed line: '#{line}'"
  end
end

ACTIONS = {
  idle: { cost: 0 },
  missile: { cost: 53, atk: 4 },
  drain: { cost: 73, atk: 2, hp: 2 },
  shield: { cost: 113, def: 7, counter: 6 },
  poison: { cost: 173, atk: 3, counter: 6 },
  recharge: { cost: 229, mana: 101, counter: 5 },
}

def player_turn(boss_hp, player_hp, player_mana, player_effects, actions, queue)
#pp turn: 'player', hp: player_hp, mana: player_mana, boss: boss_hp, prev: actions, effects: player_effects
  attack = 0
  player_effects = player_effects.select do |effect, data|
    data[:counter] -= 1
    player_mana += (data[:mana] or 0)
    attack += (data[:atk] or 0)
    player_hp += (data[:hp] or 0)
    if data[:counter] <= 0
      false
    else
      true
    end
  end
  possible_actions = ACTIONS.select { |effect, data| (not player_effects.include?(effect) and data[:cost] <= player_mana) }.keys
  possible_actions.each do |action|
    action_effects = {}
    player_effects.keys.each do |effect|
      action_effects[effect] = player_effects[effect].clone
    end
    action_attack = attack
    action_hp = player_hp
    action_mana = player_mana
    action_data = ACTIONS[action]
    action_mana -= action_data[:cost]
    if action_data[:counter]
      action_effects[action] = action_data.clone
    else
      action_attack += (action_data[:atk] or 0)
      action_hp += (action_data[:hp] or 0)
    end
    if boss_hp <= action_attack or boss_turn(boss_hp - action_attack, action_hp, action_mana, action_effects, actions + [action], queue)
      return actions + [action]
    end
  end
  return false
end

def boss_turn(boss_hp, player_hp, player_mana, player_effects, actions, queue)
#pp turn: 'boss', hp: player_hp, mana: player_mana, boss: boss_hp, prev: actions, effects: player_effects
  defense = 0
  player_effects = player_effects.select do |effect, data|
    data[:counter] -= 1
    player_mana += (data[:mana] or 0)
    boss_hp -= (data[:atk] or 0)
    if data[:counter] <= 0
      false
    else
      defense += (data[:def] or 0)
      true
    end
  end
  if boss_hp <= 0
    return true
  end
  attack = [1, (@boss_atk - defense)].max
#pp boss_atk: attack
  if player_hp > attack
    queue << [ boss_hp, player_hp - attack, player_mana, player_effects, actions ]
  end
  return false
end

def mana_to_win(starting_effects = {})
  won = false
  queue = [ [ @boss_hp, @player_hp, @player_mana, starting_effects, [] ] ]
  while not won and not queue.empty?
    boss_hp, player_hp, player_mana, player_effects, actions = queue.shift
    won = player_turn(boss_hp, player_hp, player_mana, player_effects, actions, queue)
  end
  if won
    return won.map { |action| ACTIONS[action][:cost] }.sum
  else
    raise "Lost all possible battles :("
  end
end

puts "#{mana_to_win} mana spent to win"
puts "#{mana_to_win({ hardmode: { hp: -1, counter: Float::INFINITY } })} mana spent to win in hard mode"
