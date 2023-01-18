require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip.split("\n")
#input = File.read('example').strip.split("\n")


#part 1
@ingredients = {}
input.each do |line|
  if line =~ /\A(\w+): capacity (-?\d+), durability (-?\d+), flavor (-?\d+), texture (-?\d+), calories (-?\d+)\z/
    @ingredients[Regexp.last_match[1]] = {
      capacity: Regexp.last_match[2].to_i,
      durability: Regexp.last_match[3].to_i,
      flavor: Regexp.last_match[4].to_i,
      texture: Regexp.last_match[5].to_i,
      calories: Regexp.last_match[6].to_i
    }
  else
    raise "Malformed line: #{line}"
  end
end

def gen_cookies(ingredients, remaining)
  if ingredients.empty?
    return [{
      capacity: 0,
      durability: 0,
      flavor: 0,
      texture: 0,
      calories: 0
    }]
  end
  name, data = ingredients.first
  rest_ingredients = ingredients.select { |r_name, r_data| r_name != name }
  values = []
  (0..remaining).each do |count|
    rest_values = gen_cookies(rest_ingredients, remaining - count)
    rest_values.each do |r_val|
      values << {
        capacity: r_val[:capacity] + count * data[:capacity],
        durability: r_val[:durability] + count * data[:durability],
        flavor: r_val[:flavor] + count * data[:flavor],
        texture: r_val[:texture] + count * data[:texture],
        calories: r_val[:calories] + count * data[:calories]
      }
    end
  end
  return values
end

def get_score(data)
  [data[:capacity], 0].max * [data[:durability], 0].max * [data[:flavor], 0].max * [data[:texture], 0].max
end

# This takes a while...
@all_cookies = gen_cookies(@ingredients, 100)
scores = @all_cookies.map { |data| get_score(data) }

puts "Best score: #{scores.max}"

#part 2
cookies_500cal = @all_cookies.select { |data| data[:calories] == 500 }
scores_500cal = cookies_500cal.map { |data| get_score(data) }

puts "Best score @ 500cal: #{scores_500cal.max}"
