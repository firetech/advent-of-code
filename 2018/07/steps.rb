require 'set'
require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
part2 = [
  (ARGV[1] || 5).to_i,
  (ARGV[2] || 60).to_i
]

#file = 'example1'; part2 = [2, 0]

@prereqs = {}
@steps = Set[]
File.read(file).strip.split("\n").each do |line|
  if line =~ /\AStep ([A-Z]) must be finished before step ([A-Z]) can begin\.\z/
    _, from, to = Regexp.last_match.to_a
    @steps << from
    @steps << to
    @prereqs[to] ||= Set[]
    @prereqs[to] << from
    @prereqs[from] ||= Set[]
  else
    raise "Malformed line: '#{line}'"
  end
end

# Part 1
def eligible_steps(done)
  eligible = @prereqs.select do |step, reqs|
    not done.include?(step) and (reqs - done).empty?
  end
  return eligible.keys.sort
end
steps = @steps.length
done = Set[]
result = ''
while result.length < steps
  eligible = eligible_steps(done)
  raise "Ehm..." if eligible.empty?
  step = eligible.first
  done << step
  result << step
end
puts "Step order: #{result}"

# Part 2
num_workers, base_time = part2
workers = Array.new(num_workers) { |i| [0, nil, i] }
time = 0
started = []
done = Set[]
base_time += 1 - 'A'.ord
while done.length < steps
  eligible = nil
  begin
    unless eligible.nil?
      active_workers = workers.select { |_, step| not step.nil? }
      break if active_workers.empty?
      worker = active_workers.min_by(&:first)
      time = worker[0]
      done << worker[1]
      worker[1] = nil
    end
    eligible = eligible_steps(done) - started
    free_workers = workers.select { |t, _| t <= time }
  end while eligible.empty? or free_workers.empty?
  eligible.each do |step|
    break if free_workers.empty?
    worker = free_workers.pop
    raise "Ehm..." unless worker[1].nil?
    worker[0] = time + base_time + step.ord
    worker[1] = step
    started << step
  end
end

puts "#{time} seconds needed with #{num_workers} workers"
