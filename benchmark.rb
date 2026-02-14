#!/usr/bin/env ruby

# Run the main (shortest filename) solution for all (current?) days for a
# given year, with a timer running for each.
#
# This file avoids using global ($), member (@), etc. variables, functions and
# CONSTANTS in order to not taint the namespace of the actual solutions (which
# are just load()'ed into a fork of this process.

require 'optparse'

rehearsal = false
print_usage = false
opts = OptionParser.new do |opts|
  opts.banner = "Usage: #{opts.program_name} [options] [year] [day ...]"

  opts.separator ''
  opts.separator "Will attempt to run current year (#{Time.now.year}) if " \
                 "year is not supplied."

  opts.separator ''
  opts.separator 'Options:'

  opts.on('-r',
          '--rehearse',
          'Run every day twice (first a rehearsal, then a timed run), in ' \
            'order to get the runtime environment stable, similar to ' \
            'Benchmark::bmbm') do
    rehearsal = true
  end

  opts.on('-h', '--help', 'Print this help and exit.') do
    print_usage = true
  end
end
begin
  opts.parse!
rescue => e
  print_usage = e
end

unless print_usage
  year = ARGV[0] || Time.now.year.to_s
  unless File.directory?(File.join(__dir__, year))
    print_usage = "#{year} doesn't seem to exist!"
  end
  days = ARGV[1..-1]
  if days.nil? or days.empty?
    days = '*'
  else
    formatted_days = days.map do |day|
      formatted_day = '%02i' % day.to_i(10)
      unless File.directory?(File.join(__dir__, year, formatted_day))
        print_usage = "#{year}/#{formatted_day} doesn't seem to exist!"
      end
      formatted_day
    end
    days = "{#{formatted_days.join(',')}}"
  end
end

if print_usage
  if print_usage != true
    STDERR.puts print_usage
    STDERR.puts
  end
  STDERR.puts(opts)
  exit 1
end


require 'timeout'

# Preload common libraries
require 'set'
[
  *Dir.glob(File.join(__dir__, 'lib/*.rb')),
  *Dir.glob(File.join(__dir__, year, 'lib/*.rb')),
].each do |lib|
  require lib.chomp('.rb')
end

times = {}
Dir.glob(File.join(__dir__, year, days)).sort.each do |day_folder|
  day = File.basename(day_folder)
  next unless day =~ /\A\d{1,2}\z/
  file = Dir.glob(File.join(day_folder, '*.rb')).sort_by(&:length).first
  next if file.nil?

  # Make sure input is stored.
  AOC.input_file(day, year)

  # Fork in order to not taint memory of main process.
  child = nil
  begin
    read_from_fork, write_from_fork = IO.pipe
    child = fork do
      ARGV.clear
      read_from_fork.close
      puts '-- Day %s (%s) --' % [day, File.basename(file)]
      begin
        if rehearsal
          org_stdout = STDOUT.clone
          org_constants = Module.constants
          org_loaded = $LOADED_FEATURES.clone
          begin
            STDOUT.reopen(File.new(File::NULL, 'w'))
            load(file)
          ensure
            STDOUT.reopen(org_stdout)
            (Module.constants - org_constants).each do |const|
              next if [:Z3, :FFI].include?(const) # Unloading Z3 causes issues.
              Object.send(:remove_const, const)
            end
            ($LOADED_FEATURES - org_loaded).each do |feat|
              next if feat.include?('/z3/') # Unloading Z3 causes issues.
              $LOADED_FEATURES.delete(feat)
            end
          end
        end
        GC.start
        start = Time.now
        load(file)
        done = Time.now
        result = done - start
      rescue Exception => e # Catch everything, including syntax errors
        result = e
      end
      write_from_fork.print(Marshal.dump({ last_fetch: AOC.last_fetch, result: result }))
      write_from_fork.print('__TAIL__')
    end
    write_from_fork.close
    Timeout::timeout(60) { Process.wait(child) }
    until read_from_fork.eof?
      read = read_from_fork.gets('__TAIL__')
      unless read.nil?
        data = Marshal.load(read.chomp('__TAIL__'))
        result = data[:result]
        case result
        when Exception
          raise result
        when Float
          puts '-- Runtime: %.1f ms --' % (result * 1000)
          times[day] = result
        else
          raise "Unexpected result: #{result.inspect}"
        end
        last_fetch = data[:last_fetch]
        AOC.update_last_fetch(last_fetch) unless last_fetch.nil?
      end
    end
  ensure
    [read_from_fork, write_from_fork].compact.each(&:close)
    unless child.nil?
      begin
        value = Process.wait(child, Process::WNOHANG)
        running = value.nil?
      rescue Errno::ECHILD
        running = false
      end
      if running
        Process.kill('KILL', child)
        Process.wait(child)
      end
    end
  end
  puts
end
puts 'All done!'
puts

puts "-- Sorted Runtimes for #{year} ---"
times.sort_by(&:last).reverse_each do |day, time|
  puts 'Day %s - %7.1f ms' % [day, time * 1000]
end
puts
puts 'Total: %.1f ms' % (times.values.sum * 1000)
