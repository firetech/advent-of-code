require_relative '../../lib/aoc_api'
require_relative '../lib/intcode'

input = File.read(ARGV[0] || AOC.input_file()).strip

def start_thread(name)
  return Thread.new do
    Thread.current[:name] = name
    begin
      yield
    rescue Exception => e
      puts "#{Thread.current[:name]} died: #{e.message}"
      puts "  >#{e.backtrace.join("\n  >")}" unless e.backtrace.nil?
      raise e
    end
    puts "#{Thread.current[:name]} exited?!"
  end
end

@data_lock = Mutex.new
@nat_check = ConditionVariable.new

@nic = []
@packets = {}
@received_since_last_sent = []
@nat_packet = nil
@threads = []
begin
  50.times do |i|
    @nic[i] = Intcode.new(input, false)
    @nic[i] << i
    @packets[i] = []
    @received_since_last_sent[i] = 0

    # Run and input thread
    @threads << start_thread("Run/Input ##{i}") do
      @nic[i].run do
        # Avoid livelock, encourage context switch when waiting for input
        Thread.pass

        @data_lock.synchronize do
          if not @nic[i].has_output?
            @received_since_last_sent[i] += 1
            if @received_since_last_sent[i] == 2
              @nat_check.signal
            end
          end

          if @packets[i].empty?
            -1
          else
            @packets[i].shift
          end
        end
      end
    end

    # Output thread
    @threads << start_thread("Output ##{i}") do
      while @nic[i].running? or not @nic[i].started?
        to = @nic[i].output
        @data_lock.synchronize do
          @received_since_last_sent[i] = 0
          x = @nic[i].output
          y = @nic[i].output
          if to == 255
            old_nat_packet = @nat_packet
            @nat_packet = [x, y]
            if old_nat_packet.nil?
              puts "First Y value to 255: #{y}"
              @nat_check.signal
            end
          elsif (0...50).include?(to)
            @packets[to] ||= []
            @packets[to] << [x, y]
          else
            raise "Unknown recipient: #{to}"
          end
        end
      end
    end
  end

  last_nat_sent = nil
  found = false
  until found
    @data_lock.synchronize do
      if @nat_packet.nil? or
          @packets.values.map(&:empty?).include?(false) or
          @nic.map(&:has_output?).include?(true) or
          @received_since_last_sent.min < 2
        @nat_check.wait(@data_lock)
      else
        if not last_nat_sent.nil? and not @nat_packet.nil? and
            last_nat_sent[1] == @nat_packet[1]
          puts "First repeated NAT packet Y value: #{@nat_packet[1]}"
          found = true
          break # This only breaks the synchronize block
        end
        @packets[0] << @nat_packet
        last_nat_sent = @nat_packet.dup
      end
    end
  end
rescue Exception => e
  @threads.each do |thread|
    print "#{thread[:name]}:"
    if thread.alive?
      puts "\n  >#{thread.backtrace.join("\n  >")}"
    else
      puts ' DEAD'
    end
  end
  raise e
ensure
  @threads.each(&:kill)
end
