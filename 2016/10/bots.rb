require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
target = (ARGV[1] || '17,61').split(',').map(&:to_i)

#file = 'example1'; target = [2, 3]

@bots = {}
@outputs = {}

class Bot
  def initialize(id)
    @id = id
    @inputs = Set.new
    @outputs = { low: nil, high: nil }
  end

  def name
    "bot #{@id}"
  end

  def <<(input)
    @inputs << input
    if @inputs.length == 2
      low, high = inputs
      if not @outputs[:low].nil?
        @outputs[:low] << low
      end
      if not @outputs[:high].nil?
        @outputs[:high] << high
      end
    elsif @inputs.length > 2
      raise "#{name} received more than two different inputs"
    end
  end

  def set_output(output, sink)
    if not @outputs.has_key?(output)
      raise "Unknown output: '#{output}'"
    end
    old_val = @outputs[output]
    @outputs[output] = sink
    if old_val.nil? and @inputs.length == 2
      sink << inputs[{ low: 0, high: 1 }[output]]
    end
  end

  def inputs
    @inputs.sort
  end

  def to_s
    "<#{name}, inputs: [#{inputs.join(', ')}], #{@outputs.map { |id, sink| "#{id}: #{sink.name rescue '?'}" }.join(', ')}>"
  end
  alias :inspect :to_s
end

class Output
  def initialize(id)
    @id = id
    @inputs = Set.new
  end

  def name
    "output #{@id}"
  end

  def <<(input)
    @inputs << input
    if @inputs.length > 1
      raise "#{name} received more than one different inputs"
    end
  end

  def input
    @inputs.first
  end

  def to_s
    "<#{name}, input: #{input}>"
  end
  alias :inspect :to_s
end

def get_sink(sink)
  case sink
  when /\Abot (\d+)\z/
    id = Regexp.last_match(1).to_i
    @bots[id] ||= Bot.new(id)
    @bots[id]
  when /\Aoutput (\d+)\z/
    id = Regexp.last_match(1).to_i
    @outputs[id] ||= Output.new(id)
    @outputs[id]
  else
    raise "Unknown sink: '#{sink}'"
  end
end

File.read(file).strip.split("\n").each do |line|
  case line
  when /\Avalue (\d+) goes to (bot \d+)\z/
    get_sink(Regexp.last_match(2)) << Regexp.last_match(1).to_i
  when /\A(bot \d+) gives low to ((?:bot|output) \d+) and high to ((?:bot|output) \d+)\z/
    source = get_sink(Regexp.last_match(1))
    source.set_output(:low, get_sink(Regexp.last_match(2)))
    source.set_output(:high, get_sink(Regexp.last_match(3)))
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
target_name = @bots.values.find { |bot| bot.inputs == target }.name rescue '???'
puts "#{target_name.capitalize} does comparison of #{target.join(' and ')}"

# Part 2
product = [0, 1, 2].map { |x| @outputs[x].input }.inject(&:*)
puts "Product of output 0, 1 and 2 chip values: #{product}"
