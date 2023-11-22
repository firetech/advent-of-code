require 'etc'
require 'timeout'

# Helper function for running processing on multiple CPU cores. Threading isn't
# sufficient in normal Ruby due to the Global Interpreter Lock limiting
# execution to only one thread at a time. To achieve true parallelism, we need
# to fork. Also compatibile with JRuby (which does have true parallelism, but
# can't fork).
module Multicore

  IPC_TAIL = '__IPC_OUTPUT_END__'
  IPC_WAIT = '__IPC_WAIT_INPUT__'
  IPC_ERR = '__IPC_ERROR__'
  IPC_EXIT = '__IPC_CHILD_EXIT__'

  public
  def self.run(nthreads = Etc.nprocessors)
    input_queue = Queue.new
    output_queue = Queue.new
    threads = []
    err_lock = Mutex.new
    if RUBY_PLATFORM == 'java'
      # JRuby doesn't have a GIL, just use Threads
      worker_input = -> { input_queue.pop }
      worker_output = ->(val) { output_queue << val }
      nthreads.times do |t|
        threads << Thread.new do
          yield worker_input, worker_output, t, nthreads
        end
      end

    else
      # Normal Ruby, let's fork!
      write_output = ->(output, val) do
        output.print(Marshal::dump(val))
        output.print(IPC_TAIL)
      end
      read_input = ->(input) do
        read = input.gets(IPC_TAIL)
        unless read.nil?
          read = Marshal::load(read.chomp(IPC_TAIL))
        end
        return read
      end
      nthreads.times do |t|
        threads << Thread.new do
          begin
            read_to_fork, write_to_fork = IO.pipe
            read_from_fork, write_from_fork = IO.pipe
            child = fork do
              write_to_fork.close
              read_from_fork.close
              worker_output = ->(val) do
                write_output[write_from_fork, val]
              end
              worker_input = -> do
                write_output[write_from_fork, IPC_WAIT]
                read_input[read_to_fork]
              end
              begin
                yield worker_input, worker_output, t, nthreads
              rescue Exception => e
                worker_output[IPC_ERR]
                worker_output[e]
              ensure
                worker_output[IPC_EXIT]
                write_from_fork.close
                read_to_fork.close
                exit!(0)
              end
            end
            write_from_fork.close
            read_to_fork.close
            until read_from_fork.eof?
              read = read_input[read_from_fork]
              case read
              when IPC_WAIT
                write_output[write_to_fork, input_queue.pop]
              when IPC_ERR
                e = read_input[read_from_fork]
                err_lock.synchronize do
                  print_exception("Child #{t} raised", e)
                end
              when IPC_EXIT
                break
              else
                output_queue << read
              end
            end
            # Expect child to exit quickly after pipe is closed.
            begin
              Timeout::timeout(1) { Process.wait(child) }
            rescue Errno::ECHILD
              # Ignore
            rescue Timeout::Error
              raise 'Output reached EOF and child did not stop.'
            end
          ensure
            [read_to_fork, write_to_fork].compact.each(&:close)
            [read_from_fork, write_from_fork].compact.each(&:close)
            if not child.nil? and child_running?(child)
              Process.kill('KILL', child)
              Process.wait(child)
            end
          end
        end
      end
    end

    stop = -> do
      threads.each(&:kill)
      threads.each_with_index do |thr, t|
        begin
          thr.join
        rescue Exception => e
          print_exception("Thread #{t} raised", e)
        end
      end
    end
    return input_queue, output_queue, stop
  end

  private
  def self.child_running?(child)
    begin
      value = Process.wait(child, Process::WNOHANG)
      return value.nil?
    rescue Errno::ECHILD
      return false
    end
  end

  private
  def self.print_exception(header, e)
    puts "#{header}: #{e.message}"
    (e.backtrace or ['(No backtrace)']).each do |line|
      puts "\t#{line}"
    end
  end
end
