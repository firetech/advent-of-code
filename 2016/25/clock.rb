require_relative '../../lib/aoc'
require_relative '../../lib/multicore'
require_relative '../lib/assembunny'

def check_clock(cpu, start_a)
  begin
    cpu.flush
    cpu_thread = Thread.new { cpu.run(a: start_a) }
    last_out = nil
    length = 0
    loop do
      out = cpu.output
      if not last_out.nil? and 1 - out != last_out
        break
      elsif (length += 1) >= 15
        return true
      end
      last_out = out
    end
  ensure
    cpu_thread.kill
    cpu_thread.join
  end
  return false
end

stop = nil
begin
  input, output, stop = Multicore.run do |_, worker_out, a, nthreads|
    assembunny = AssemBunny.new(ARGV[0] || AOC.input_file())
    loop do
      break if check_clock(assembunny, a)
      a += nthreads
    end
    worker_out[a]
  end
  input.close
  puts "Lowest clock value: #{output.pop}"
ensure
  stop[] unless stop.nil?
end
