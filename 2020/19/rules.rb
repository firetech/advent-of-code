require 'set'
require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

input_rules, input_msgs = File.read(file).strip.split("\n\n").map do |block|
  block.split("\n")
end

@rules = {}
input_rules.each do |line|
  if line =~ /\A(\d+): (((\d+|\|)( |\z))+|"(.+)"\z)\z/
    rule = Regexp.last_match(1).to_i
    if Regexp.last_match(6)
      @rules[rule] = Regexp.last_match(6)
    else
      blocks = Regexp.last_match(2).split(' | ').map do |block|
        parts = block.split(' ').map(&:to_i)
        if parts.length == 1
          parts.first
        else
          # Array means concatenation
          parts
        end
      end
      if blocks.length == 1
        @rules[rule] = blocks.first
      else
        # Set means OR
        @rules[rule] = Set.new(blocks)
      end
    end
  else
    raise "Malformed rule: '#{line}'"
  end
end

def build_regexp(rule = 0, cache = {})
  case rule
  when Numeric
    if not cache.has_key?(rule)
      cache[rule] = "\\g<rule#{rule}>" # Handle recursive rules
      regexp = build_regexp(@rules[rule], cache)
      if regexp.include?(cache[rule])
        regexp = "(?<rule#{rule}>#{regexp})"
      end
      cache[rule] = regexp
    end
    return cache[rule]
  when String
    return rule
  when Set
    return "(#{rule.map { |block| build_regexp(block, cache) }.join('|')})"
  when Array
    return rule.map { |block| build_regexp(block, cache) }.join
  else
    raise "Unexpected rule content: #{content.class.name}"
  end
end

def count_matches(msgs)
  pattern = /\A#{build_regexp}\z/
  return msgs.count { |msg| pattern.match?(msg) }
end


=begin
# I initially solved part 1 using Regexp (basically the code above), but thought that recursion in part 2 would be impossible.
# This is my original solution for part 2, before learning about recursive matches in Regexp (\g in Ruby).
# Slow, but still finishes within a few seconds.

def match_rule(strs, rule = 0)
  if not strs.is_a? Array
    strs = [ strs ]
  end
  leftovers = []
  case rule
  when Numeric
    return match_rule(strs, @rules[rule])
  when String
    strs.each do |str|
      if str.start_with?(rule)
        leftovers << str[rule.length..-1]
      end
    end
  when Set
    strs.each do |str|
      rule.each do |block|
        leftovers += match_rule(str, block)
      end
    end
  when Array
    strs.each do |str|
      this_leftovers = str
      rule.each do |part|
        this_leftovers = match_rule(this_leftovers, part)
        if this_leftovers.empty?
          break
        end
      end
      if not this_leftovers.empty?
        leftovers += this_leftovers
      end
    end
  else
    raise "Unexpected rule content: #{rule.class.name}"
  end
  return leftovers
end

def count_matches(msgs)
  msgs.count { |msg| match_rule(msg).any?(&:empty?) }
end
=end


# Part 1
puts "#{count_matches(input_msgs)} matching messages."

# Part 2
@rules[8] = Set[42, [42, 8]]
@rules[11] = Set[[42, 31], [42, 11, 31]]
puts "#{count_matches(input_msgs)} matching messages after changing rule 8 and 11."
