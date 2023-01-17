require 'set'
require_relative '../../lib/aoc_api'
require_relative '../../lib/multicore'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

class Beacon
  attr_reader :id, :pos, :relations

  def initialize(id, pos)
    @id = id
    @pos = pos
    @relations = []
  end

  def delta_to(other)
    @pos.zip(other.pos).map { |p, o| p - o }
  end

  def relate_to!(other)
    delta = delta_to(other).map(&:abs)
    fingerprint = delta.sort.hash
    @relations[other.id] = other.relations[@id] = fingerprint
  end

  def match(other)
    matches = []
    @relations.each_with_index do |rel, i|
      next if rel.nil?  # The relation with self is not really helpful
      other_i = other.relations.index(rel)
      matches << [i, other_i] unless other_i.nil?
    end
    return matches
  end

  def rotate!(matrix)
    @pos = [
      @pos[0] * matrix[0][0] + @pos[1] * matrix[1][0] + @pos[2] * matrix[2][0],
      @pos[0] * matrix[0][1] + @pos[1] * matrix[1][1] + @pos[2] * matrix[2][1],
      @pos[0] * matrix[0][2] + @pos[1] * matrix[1][2] + @pos[2] * matrix[2][2]
    ]
  end

  def translate!(delta)
    @pos = @pos.zip(delta).map { |a, b| a + b }
  end
end

class Scanner
  attr_reader :id, :beacons
  attr_accessor :pos

  def initialize(id)
    @id = id
    @pos = [0, 0, 0]
    @beacons = []
  end

  def <<(beacon_pos)
    new_beacon = Beacon.new(@beacons.length, beacon_pos)
    @beacons.each do |beacon|
      new_beacon.relate_to!(beacon)
    end
    @beacons << new_beacon
  end

  def match(other)
    other.beacons.each do |other_beacon|
      @beacons.each do |my_beacon|
        matches = my_beacon.match(other_beacon)
        if matches.length >= 11  # == 12 matches including the compared beacons
          return my_beacon, other_beacon, matches
        end
      end
    end
    return nil
  end

  def align_to!(other)
    my_beacon, other_beacon, matches = match(other)
    return false if my_beacon.nil?

    matches.each do |i, other_i|
      my_rel = @beacons[i]
      other_rel = other.beacons[other_i]

      my_delta = my_beacon.pos.zip(my_rel.pos).map { |a, b| a - b }
      next if my_delta.map(&:abs).uniq.length < 3
      other_delta = other_beacon.pos.zip(other_rel.pos).map { |a, b| a - b }

      rot_matrix = Array.new(3) do |row|
        Array.new(3) do |col|
          my_val = my_delta[row]
          other_val = other_delta[col]
          if my_val == other_val
            1
          elsif my_val == -other_val
            -1
          else
            0
          end
        end
      end

      @beacons.each do |beacon|
        beacon.rotate!(rot_matrix)
      end
      @pos = other_beacon.delta_to(my_beacon)
      @beacons.each do |beacon|
        beacon.translate!(@pos)
      end
      break
    end
    return true
  end
end


@scanners = {}
curr_scanner = nil
File.read(file).strip.split("\n").each do |line|
  case line
  when /\A--- scanner (\d+) ---\z/
    id = Regexp.last_match(1).to_i
    curr_scanner = Scanner.new(id)
    @scanners[id] = curr_scanner
  when /\A(-?\d+),(-?\d+),(-?\d+)\z/
    raise "Unexpected coordinates" if curr_scanner.nil?
    curr_scanner << Regexp.last_match.to_a[1..-1].map(&:to_i)
  when ''
    # Ignore
  else
    raise "Malformed line: '#{line}'"
  end
end

aligned_scanners = Set[0]
tried = Set[]
@beacons = Set.new(@scanners[0].beacons.map(&:pos))
begin
  input, output, stop = Multicore.run do |worker_in, worker_out, _, _|
    loop do
      scanner, candidates = worker_in[]
      break if scanner.nil?
      aligned = false
      candidates.each do |aligned_scanner|
        if scanner.align_to!(aligned_scanner)
          aligned = true
          break
        end
      end
      worker_out[[aligned, scanner]]
    end
  end
  while aligned_scanners.length < @scanners.length
    inputs_sent = 0
    candidate_ids = (aligned_scanners - tried)
    tried += candidate_ids
    candidates = candidate_ids.map { |id| @scanners[id] }
    @scanners.each do |id, scanner|
      next if aligned_scanners.include?(id)
      input << [scanner, candidates]
      inputs_sent += 1
    end
    inputs_sent.times do
      aligned, scanner = output.pop
      raise "Worker returned nil" if aligned.nil?
      if aligned
        puts "Found alignment for scanner #{scanner.id}"
        aligned_scanners << scanner.id
        @scanners[scanner.id] = scanner
        @beacons += scanner.beacons.map(&:pos)
      end
    end
  end
  raise "Unexpected output" unless output.empty?
ensure
  stop[] unless stop.nil?
end
puts

# Part 1
puts "Beacons found: #{@beacons.length}"

# Part 2
distances = @scanners.values.map(&:pos).combination(2).map do |a, b|
  a.zip(b).map { |aa, bb| (aa - bb).abs }.sum
end
puts "Largest manhattan distance between scanners: #{distances.max}"
