require_relative '../../lib/aoc'
require_relative '../lib/intcode'

input = File.read(ARGV[0] || AOC.input_file()).split(',').map(&:to_i)

#part 1
amp = Intcode.new(input, false)

values = (0..4).to_a.permutation.map do |order|
  val = 0
  order.each do |phase|
    amp.reset
    amp.input(phase)
    amp.input(val)
    amp.run
    val = amp.output
  end
  val
end

puts "Max result (0..4): #{values.max}"

#part 2
amps = 5.times.map { Intcode.new(input, false) }
in_amps = amps.clone
in_amps.unshift(in_amps.pop)
values = (5..9).to_a.permutation.map do |order|
  amps.each(&:reset)
  amps.zip(order) do |amp, phase|
    amp.input(phase)
  end
  amps.first.input(0)
  threads = []
  amps.zip(in_amps) do |amp, in_amp|
    threads << Thread.new do
      amp.run { in_amp.output }
    end
  end
  threads.each(&:join)
  amps.last.output
end

puts "Max result (5..9): #{values.max}"
