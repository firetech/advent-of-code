require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

# My initial, more naïve solution. It works, but is about 30x slower than the
# final version.

class Scanner
  attr_reader :range, :pos

  def initialize(range)
    @range = range
    reset
  end

  def reset
    @pos = 0
    @dir = 1
  end

  def tick
    @pos += @dir
    if [0, @range - 1].include?(@pos)
      @dir = -@dir
    end
  end
end

@scanners = {}
File.read(file).strip.split("\n").each do |line|
  if line =~ /\A(\d+): (\d+)\z/
    depth = Regexp.last_match(1).to_i
    range = Regexp.last_match(2).to_i
    if @scanners.has_key?(depth)
      raise "Duplicate depth: #{depth}"
    end
    @scanners[depth] = Scanner.new(range)
  else
    raise "Malformed line: '#{line}'"
  end
end
@max_depth = @scanners.keys.max

# Part 1
depth = 0
severity = 0
while depth <= @max_depth
  scanner = @scanners[depth]
  if not scanner.nil? and scanner.pos == 0
    severity += depth * scanner.range
  end
  @scanners.values.each(&:tick)
  depth += 1
end
puts "Severity of starting immediately: #{severity}"

# Part 2
# Reset to a delay of 1 ps
@scanners.values.each(&:reset)
@scanners.values.each(&:tick)
delay = 1
# Pipelining multiple packets at the same time :)
passages = { 1 => 0 }
while not passages.values.include?(@max_depth+1)
  passages.keys.each do |p_delay|
    depth = passages[p_delay]
    scanner = @scanners[depth]
    if not scanner.nil? and scanner.pos == 0
      passages.delete(p_delay)
    else
      passages[p_delay] += 1
    end
  end
  @scanners.values.each(&:tick)
  delay += 1
  passages[delay] = 0
end

safe_delay = passages.select { |k,v| v == @max_depth+1 }.keys.first
puts "Delay needed for safe passage: #{safe_delay}"
