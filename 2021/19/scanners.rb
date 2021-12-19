require 'matrix'
require 'set'
require '../../lib/multicore'

file = 'input'
#file = 'example1'

@scanners = {}
curr_scanner = nil
File.read(file).strip.split("\n").each do |line|
  case line
  when /\A--- scanner (\d+) ---\z/
    curr_scanner = []
    @scanners[Regexp.last_match(1).to_i] = curr_scanner
  when /\A(-?\d+),(-?\d+),(-?\d+)\z/
    raise "Unexpected coordinates" if curr_scanner.nil?
    curr_scanner << Regexp.last_match.to_a[1..-1].map(&:to_i)
  when ''
    # Ignore
  else
    raise "Malformed line: '#{line}'"
  end
end

FACING = [
  Vector[ 1,  0,  0],
  Vector[-1,  0,  0],
  Vector[ 0,  1,  0],
  Vector[ 0, -1,  0],
  Vector[ 0,  0,  1],
  Vector[ 0,  0, -1]
]

ROTATIONS = FACING.flat_map do |facing|
  matrixes = []
  FACING.each do |up|
    unless facing.zip(up).all? { |f, u| f.abs == u.abs }
      right = facing.cross_product(up)
      matrixes << Matrix[facing, up, right]
    end
  end
  matrixes
end

@rotations = {}
@scanners.each do |id, beacons|
  next if id == 0  # 0 is used as base, no need to rotate it
  @rotations[id] = ROTATIONS.map do |rot_matrix|
    beacons.map { |pos| (rot_matrix * Vector.elements(pos)).to_a }
  end
end

def rebase_scanner(id, beacons)
  @rotations[id].each do |rotated_scanner|
    matching = {}
    rotated_scanner.each_with_index do |rpos, i|
      beacons.each do |aligned_pos|
        delta = aligned_pos.zip(rpos).map { |a, r| a - r }
        match = (matching[delta] ||= Set[])
        next if match.include?(i)
        match << i
        if match.length >= 12
          translated_scanner = rotated_scanner.map do |pos|
            pos.zip(delta).map { |p, d| p + d }
          end
          return id, delta, translated_scanner
        end
      end
    end
  end
  return id, nil, nil
end

@beacons = Set.new(@scanners[0])
@aligned_scanners = { 0 => [0, 0, 0] }
begin
  input, output, stop = Multicore.run do |worker_in, worker_out, t, _|
    loop do
      id, beacons = worker_in[]
      break if id.nil?
      worker_out[rebase_scanner(id, beacons)]
    end
  end
  while @aligned_scanners.length < @scanners.length
    inputs_sent = 0
    @scanners.each_key do |id|
      next if @aligned_scanners.has_key?(id)
      input << [id, @beacons]
      inputs_sent += 1
    end
    inputs_sent.times do
      id, scanner_pos, aligned_beacons = output.pop
      raise "Worker returned nil" if id.nil?
      unless scanner_pos.nil?
        puts "Found alignment for scanner #{id}"
        @beacons += aligned_beacons
        @aligned_scanners[id] = scanner_pos
      end
    end
  end
  raise "Unexpected output" unless output.empty?
ensure
  stop[] unless stop.nil?
end

# Part 1
puts "Beacons found: #{@beacons.length}"

# Part 2
distances = @aligned_scanners.values.combination(2).map do |a, b|
  a.zip(b).map { |aa, bb| (aa - bb).abs }.sum
end
puts "Largest manhattan distance between scanners: #{distances.max}"
