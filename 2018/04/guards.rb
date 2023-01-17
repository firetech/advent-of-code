require 'time'
require_relative '../../lib/aoc_api'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

log = []
File.read(file).strip.split("\n").each do |line|
  if line =~ /\A\[(\d{4}-\d\d-\d\d \d\d:\d\d)\] (.+)\z/
    _, timestamp, event_str = Regexp.last_match.to_a
    event = case event_str
            when /\AGuard #(\d+) begins shift\z/
              [:guard, Regexp.last_match(1).to_i]
            when 'falls asleep'
              [:sleep]
            when 'wakes up'
              [:wake]
            else
              raise "Malformed event: '#{event_str}'"
            end
    log << [Time.parse(timestamp), *event]
  else
    raise "Malformed line: '#{line}'"
  end
end

@asleep = {}
current_guard = nil
sleep_start = nil
log.sort_by! { |timestamp, _, _| timestamp }.each do |timestamp, event, guard|
  guard ||= current_guard
  case event
  when :guard
    raise "Last guard is asleep" unless sleep_start.nil?
    current_guard = guard
  when :sleep
    raise "No guard" if guard.nil?
    raise "Asleep outside midnight hour" if timestamp.hour != 0
    sleep_start = timestamp
  when :wake
    raise "Wake up without sleep" if sleep_start.nil?
    raise "Asleep outside midnight hour" if timestamp.hour != 0
    @asleep[guard] ||= Hash.new(0)
    sleep_start.min.upto(timestamp.min - 1) do |min|
      @asleep[guard][min] += 1
    end
    sleep_start = nil
  end
end
raise "Last guard never woke up" unless sleep_start.nil?

# Part 1
worst_guard, w_sleeps = @asleep.max_by { |_, log| log.values.sum }
best_min, _ = w_sleeps.max_by { |_, x| x }

puts "Strategy 1: Guard ##{worst_guard}, minute #{best_min}"
puts "#{worst_guard} * #{best_min} = #{worst_guard * best_min}"

# Part 2
most_minute = @asleep.transform_values { |log| log.max_by { |_, x| x } }
worst_guard, min_data = most_minute.max_by { |_, (_, x)| x }
best_min, _ = min_data

puts "Strategy 2: Guard ##{worst_guard}, minute #{best_min}"
puts "#{worst_guard} * #{best_min} = #{worst_guard * best_min}"
