require 'digest/md5'
require_relative '../../lib/aoc'

@input = ARGV[0] || AOC.input()
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
require_relative '../../lib/multicore'

@hashes = []
@waiting = nil  # Set from Multicore below
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

stop = nil
read_thread = nil
begin
  t = Time.now
  input, output, stop = Multicore.run do |worker_in, worker_out, t, _|
    loop do
      index = worker_in[]
      worker_out[[index, calc_hash(index)]]
    end
  end
  @waiting = input
  # Queue up a big amount of hashes to be calculated.
  # If this is lower than the answer, only one thread will be active in the end.
  25000.times { |i| get_hash(i, false) }
  read_thread = Thread.new do
    loop do
      index, hash = output.pop
      store_hash(index, hash) unless index.nil?
    end
  end
  index2 = find_64th { |index| get_hash(index) }
  puts "Part 2 calculation time: #{(Time.now - t).round(2)}s"
  puts "Index of 64th one-time pad key with stretching: #{index2}"
ensure
  stop[] unless stop.nil?
  unless read_thread.nil?
    read_thread.kill
    read_thread.join
  end
end
