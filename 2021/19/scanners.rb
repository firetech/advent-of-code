require 'matrix'
require 'set'

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
    curr_scanner << Vector.elements(Regexp.last_match.to_a[1..-1].map(&:to_i))
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

@rotation_cache = {}
def rebase_scanner(id, raw_scanner)
  rotations = @rotation_cache[id]
  if rotations.nil?
    rotations = ROTATIONS.map do |rotation|
      raw_scanner.map { |pos| rotation * pos }
    end
    @rotation_cache[id] = rotations
  end
  rotations.each do |rotated_scanner|
    rotated_scanner.each do |rpos|
      @beacons.each do |aligned_pos|
        delta = aligned_pos - rpos
        translated_scanner = rotated_scanner.map { |pos| pos + delta }
        if (@beacons & translated_scanner).length >= 12
          return delta, translated_scanner
        end
      end
    end
  end
  return nil
end

@beacons = Set.new(@scanners[0])
@aligned_scanners = { 0 => Vector[0, 0, 0] }
while @aligned_scanners.length < @scanners.length
  @scanners.each do |id, raw_scanner|
    next if @aligned_scanners.has_key?(id)
    scanner_pos, scanner_beacons = rebase_scanner(id, raw_scanner)
    unless scanner_pos.nil?
      puts "Found alignment for scanner #{id}"
      @beacons += scanner_beacons
      @aligned_scanners[id] = scanner_pos
    end
  end
end

# Part 1
puts "Beacons found: #{@beacons.length}"

# Part 2
distances = @aligned_scanners.values.combination(2).map do |a, b|
  (a - b).map(&:abs).sum
end
puts "Largest manhattan distance between scanners: #{distances.max}"
