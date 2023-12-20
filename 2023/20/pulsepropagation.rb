require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

@modules = {}
File.read(file).rstrip.split("\n").each do |line|
  case line
  when /\A([%&])?([a-z]+) -> ([a-z, ]+)\z/
    type = Regexp.last_match(1)
    name = Regexp.last_match(2).to_sym
    recipients = Regexp.last_match(3).split(', ').map(&:to_sym)
    memory = nil
    if type.nil?
      raise "Unexpected typeless module: '#{line}'" if name != :broadcaster
    else
      type = type.to_sym
      case type
      when :%
        memory = false
      when :&
        memory = {}
      end
    end
    @modules[name] = {
      type: type,
      recipients: recipients,
      memory: memory
    }
  else
    raise "Malformed line: '#{line}'"
  end
end
# Add all inputs to conjunction modules' memories
@modules.each_key do |name|
  @modules[name][:recipients].each do |r_name|
    r = @modules[r_name]
    next if r.nil? or r[:type] != :&
    r[:memory][name] = 0
  end
end

def push(modules, count = {})
  queue = [[:button, 0, :broadcaster]]
  until queue.empty?
    src, value, name = queue.shift
    count[name] ||= Hash.new(0)
    count[name][value] += 1
    mod = modules[name]
    next if mod.nil?

    case mod[:type]
    when nil
      mod[:recipients].each do |rec|
        queue << [name, value, rec]
      end
    when :%
      if value == 0
        mod[:memory] = !mod[:memory]
        output = mod[:memory] ? 1 : 0
        mod[:recipients].each do |rec|
          queue << [name, output, rec]
        end
      end
    when :&
      mod[:memory][src] = value
      output = mod[:memory].values.all?(1) ? 0 : 1
      mod[:recipients].each do |rec|
        queue << [name, output, rec]
      end
    end
  end
  return count
end

# Part 1
modules = @modules.transform_values(&:clone)
count = {}
1000.times do
  count = push(modules, count)
end
low_count = 0
high_count = 0
count.each_value do |c|
  low_count += c[0]
  high_count += c[1]
end
puts "Product of low and high pulse counts: #{low_count * high_count}"

# Part 2
watch_modules = [:rx]
watch_output = 0
while watch_modules.length == 1
  watch_modules = @modules.select { |_, mod| not (mod[:recipients] & watch_modules).empty? }.map(&:first)
  watch_output = 1 - watch_output
  unless watch_modules.empty?
    if watch_modules.length == 1
      is_inverter = @modules[watch_modules.first][:type] == :&
      raise 'Single module on route to rx not a conjunction!' unless is_inverter
    else
      # This likely never happens, as it'd make the solution too simple.
      raise 'Even number of inverters on route to rx!' unless watch_output == 0
    end
  end
end
cycle_start = {}
cycle_end = {}
cycle = 0
modules = @modules.transform_values(&:clone)
until cycle_end.length == watch_modules.length
  cycle += 1
  count = push(modules)
  watch_modules.each do |name|
    if count[name][watch_output] > 0
      if cycle_start[name].nil?
        cycle_start[name] = cycle
      elsif cycle_end[name].nil?
        cycle_end[name] = cycle
      end
    end
  end
end
cycle_start.each do |name, start|
  if cycle_end[name] - start != start
    raise "Cycle length for #{name.to_s} not equal to cycle start, more mathing needed!"
  end
end
puts "Button pushes needed for low pulse to rx: #{cycle_start.values.inject(&:lcm)}"
