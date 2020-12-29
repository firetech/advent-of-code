require_relative '../lib/assembunny'
require 'etc'

assembunny = AssemBunny.new('input')

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

nthreads = Etc.nprocessors
queue = Queue.new
begin
  threads = nthreads.times.map do |thread_a|
    Thread.new do
      if RUBY_PLATFORM != 'java'
        # Because of normal Ruby's GIL, we need to fork to achieve true parallelism.
        begin
          read_from_fork, write_from_fork = IO.pipe
          child = fork do
            read_from_fork.close
            loop do
              if check_clock(assembunny, thread_a)
                break
              end
              thread_a += nthreads
            end
            write_from_fork.puts(thread_a.to_s)
            write_from_fork.close
            exit!(0)
          end
          write_from_fork.close
          queue << read_from_fork.gets.to_i
        ensure
          [read_from_fork, write_from_fork].each(&:close)
          Process.kill('KILL', child)
          Process.wait(child)
        end
      else
        thread_bunny = thread_a == 0 ? assembunny : assembunny.clone
        # JRuby doesn't have a GIL
        loop do
          if check_clock(thread_bunny, thread_a)
            break
          end
          thread_a += nthreads
        end
        queue << thread_a
      end
    end
  end
  puts "Lowest clock value: #{queue.pop}"
ensure
  threads.each(&:kill)
  threads.each(&:join)
end

