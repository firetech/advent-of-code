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
# Keep track of inputs and add all inputs to conjunction modules' memories
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
rx_inputs = @modules.select { |_, mod| mod[:recipients].include?(:rx) }.map(&:first)
raise 'Wat.' if rx_inputs.length > 1
watch_modules = @modules.select { |_, mod| not (mod[:recipients] & rx_inputs).empty? }.map(&:first)
cycles = {}
cycle = 0
modules = @modules.transform_values(&:clone)
until cycles.length == watch_modules.length
  cycle += 1
  count = push(modules)
  watch_modules.each do |name|
    if count[name][0] > 0
      cycles[name] = cycle
    end
  end
end
puts "Button pushes needed for low pulse to rx: #{cycles.values.inject(&:lcm)}"
