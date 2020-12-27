require 'digest/md5'
require 'etc'

@input = 'cuanljph'
#@input = 'abc'

def find_64th
  index = 0
  candidates = Array.new(16) { [] }
  found = []

  while found.length < 64
    hash = yield index
    hash.scan(/([0-9a-f])\1\1\1\1/) do |c|
      c = c[0].to_i(16)
      found += candidates[c].reject { |i| i <= index - 1000 }
      candidates[c].clear
    end
    if hash =~ /([0-9a-f])\1\1/
      candidates[Regexp.last_match(1).to_i(16)] << index
    end
    index += 1
  end
  return found.sort[63]
end

##########
# Part 1 #
##########
index1 = find_64th do |index|
  Digest::MD5.hexdigest(@input + index.to_s)
end
puts "Index of 64th one-time pad key: #{index1}"

##########
# Part 2 #
##########
@hashes = []
@waiting = Queue.new
@mutex = Mutex.new
def get_hash(index, blocking = true)
  @mutex.synchronize do
    val = @hashes[index]
    if val.nil?
      @waiting << index
      @hashes[index] = ConditionVariable.new
    end
    while @hashes[index].is_a?(ConditionVariable)
      if blocking
        @hashes[index].wait @mutex
      else
        return nil
      end
    end
    return @hashes[index]
  end
end

def calc_hash(index)
  hash = Digest::MD5.hexdigest(@input + index.to_s)
  2016.times { hash = Digest::MD5.hexdigest(hash) }
  return hash
end

def store_hash(index, hash)
  @mutex.synchronize do
    cv = @hashes[index]
    @hashes[index] = hash
    cv.broadcast
  end
end

# Queue up a big amount of hashes to be calculated.
# If this is lower than the answer, only one thread will be active in the end.
25000.times { |i| get_hash(i, false) }

workers = []
begin
  t = Time.now
  Etc.nprocessors.to_i.times do |t|
    workers << Thread.new do
      if RUBY_PLATFORM != 'java'
        # Because of normal Ruby's GIL, we need to fork to achieve true parallelism.
        begin
          read_from_fork, write_from_fork = IO.pipe
          read_to_fork, write_to_fork = IO.pipe
          child = fork do
            read_from_fork.close
            write_to_fork.close
            while index = read_to_fork.gets
              begin
                write_from_fork.puts(calc_hash(index.strip))
              rescue Errno::EPIPE
                break
              end
            end
            write_from_fork.close
            read_to_fork.close
            exit!(0)
          end
          write_from_fork.close
          read_to_fork.close
          while not (Process.getpgid(child) rescue nil).nil? and index = @waiting.pop
            write_to_fork.puts(index.to_s)
            hash = read_from_fork.gets
            store_hash(index, hash.strip)
          end
        ensure
          [read_from_fork, write_from_fork, read_to_fork, write_to_fork].each(&:close)
          Process.kill('KILL', child)
          Process.wait(child)
        end
      else
        # JRuby doesn't have a GIL
        while index = @waiting.pop
          store_hash(index, calc_hash(index))
        end
      end
    end
  end

  index2 = find_64th { |index| get_hash(index) }
  puts "Part 2 calculation time: #{(Time.now - t).round(2)}s"
ensure
  workers.each do |worker|
    if worker.status
      worker.kill
      worker.join
    end
  end
end
puts "Index of 64th one-time pad key with stretching: #{index2}"
