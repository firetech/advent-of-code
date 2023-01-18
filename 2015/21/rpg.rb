require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()

me = { hp: 100, d: 0, a: 0 }

boss = {}
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\AHit Points: (\d+)\z/
    boss[:hp] = Regexp.last_match(1).to_i
  when /\ADamage: (\d+)\z/
    boss[:d] = Regexp.last_match(1).to_i
  when /\AArmor: (\d+)\z/
    boss[:a] = Regexp.last_match(1).to_i
  else
    raise "Malformed line: '#{line}'"
  end
end

shop = {
  weapons: {
    min: 1,
    max: 1,
    articles: {
      8 => { d: 4, a: 0 },
      10 => { d: 5, a: 0 },
      25 => { d: 6, a: 0 },
      40 => { d: 7, a: 0 },
      74 => { d: 8, a: 0 }
    }
  },
  armor: {
    min: 0,
    max: 1,
    articles: {
      13 => { d: 0, a: 1 },
      31 => { d: 0, a: 2 },
      53 => { d: 0, a: 3 },
      75 => { d: 0, a: 4 },
      102 => { d: 0, a: 5 }
    }
  },
  rings: {
    min: 0,
    max: 2,
    articles: {
      20 => { d: 0, a: 1 },
      25 => { d: 1, a: 0 },
      40 => { d: 0, a: 2 },
      50 => { d: 2, a: 0 },
      80 => { d: 0, a: 3 },
      100 => { d: 3, a: 0 }
    }
  }
}

def wins_fight?(me, boss)
  while me[:hp] > 0 and boss[:hp] > 0
    [[me, boss], [boss, me]].each do |attacker, victim|
      victim[:hp] -= [1, attacker[:d] - victim[:a]].max
      if victim[:hp] <= 0
        break
      end
    end
  end
  return me[:hp] > 0
end

combinations = shop.map do |type, data|
  (data[:min]..data[:max]).flat_map{ |n| data[:articles].keys.combination(n).to_a }
end

min_win = Float::INFINITY # Part 1
max_lose = -Float::INFINITY # Part 2
combinations.first.product(*combinations[1..-1]) do |weapon, armor, rings|
  shopped_me = me.clone
  sum = 0
  { weapons: weapon, armor: armor, rings: rings }.each do |type, items|
    items.each do |item|
      sum += item
      item_data = shop[type][:articles][item]
      shopped_me[:d] += item_data[:d]
      shopped_me[:a] += item_data[:a]
    end
  end
  win = false
  if sum < min_win or sum > max_lose
    win = wins_fight?(shopped_me, boss.clone)
  end
  if win and sum < min_win
    min_win = sum
  end
  if not win and sum > max_lose
    max_lose = sum
  end
end
puts "Minimum gold spent to win: #{min_win}"
puts "Maximum gold spent to lose: #{max_lose}"
