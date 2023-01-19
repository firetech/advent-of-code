require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

possible_allergens = {}
ingredient_occurrences = Hash.new(0)
File.read(file).strip.split("\n").each do |line|
  if line =~ /\A([\w ]+) \(contains ([\w, ]+)\)\z/
    ingredients = Set.new(Regexp.last_match(1).split(' '))
    ingredients.each do |ingredient|
      ingredient_occurrences[ingredient] += 1
    end
    Regexp.last_match(2).split(', ').each do |allergen|
      if possible_allergens.has_key?(allergen)
        possible_allergens[allergen] &= ingredients
      else
        possible_allergens[allergen] = ingredients
      end
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
safe_ingredients = Set.new(ingredient_occurrences.keys)
possible_allergens.each do |allergen, ingredients|
  safe_ingredients -= ingredients
end
safe_occurrences = safe_ingredients.map { |i| ingredient_occurrences[i] }.sum
puts "Safe ingredients are appearing #{safe_occurrences} times"


# Part 2
allergens = {}
while possible_allergens.values.count(&:empty?) < possible_allergens.length
  possible_allergens.each do |allergen, ingredients|
    if ingredients.length == 1
      allergens[allergen] = ingredients.first
      possible_allergens.keys.each do |allergen|
        possible_allergens[allergen] -= ingredients
      end
    end
  end
end
canonical_list = allergens.sort_by(&:first).map(&:last).join(',')
puts "Canonical dangerous ingredient list: #{canonical_list}"
