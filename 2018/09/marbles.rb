require_relative '../../lib/aoc_api'

input = nil
#input = [9, 25]
#input = [10, 1618]
#input = [30, 5807]

if input.nil?
  if ARGV.length == 0
    File.read(AOC.input_file()).rstrip.split("\n").each do |line|
      case line
      when /\A(\d+) players; last marble is worth (\d+) points\z/
        input = [
          Regexp.last_match(1).to_i,
          Regexp.last_match(2).to_i,
          Regexp.last_match(2).to_i * 100
        ]
      else
        raise "Malformed line: '#{line}'"
      end
    end
  elsif ARGV.length >= 2
    input = ARGV.map(&:to_i)
  else
    raise ArgumentError, "Expected 0 or >=2 arguments, got 1"
  end
end

class Marble
  attr_reader :value, :next, :prev

  def initialize(value)
    @value = value
    @next = self
    @prev = self
  end

  def insert_after(marble)
    self.next = marble.next
    self.prev = marble
    marble.next = self
    self.next.prev = self
  end

  def remove
    self.prev.next = self.next
    self.next.prev = self.prev
    return @value
  end

  protected
  attr_writer :next, :prev
end

@players, *@last_marble = input

current = Marble.new(0)
player = 0
scores = Array.new(@players, 0)
last_end = 0
@last_marble.each do |max|
  (last_end+1).upto(max) do |value|
    if value % 23 == 0
      scores[player] += value
      current = current.prev.prev.prev.prev.prev.prev
      scores[player] += current.prev.remove
    else
      new = Marble.new(value)
      new.insert_after(current.next)
      current = new
    end
    player = (player + 1) % @players
  end
  last_end = max
  puts "Winning Elf's score after #{max} marbles: #{scores.max}"
end
