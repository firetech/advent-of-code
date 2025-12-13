require_relative '../../lib/aoc'

file = ARGV[0] || AOC.input_file()
#file = 'example1'

*presents, regions = File.read(file).rstrip.split("\n\n")

# "Borrowed" from 2020/20/puzzle_simpler.rb
def arrangements(body)
  t_body = body.transpose
  [
    body, # original
    body.reverse, # flipped vertically
    body.map(&:reverse), # flipped horizontally
    body.map(&:reverse).reverse, # both flipped (rotated 180deg)
    t_body, # ...and the same for the transposed data (flipped diagonally)
    t_body.reverse,
    t_body.map(&:reverse),
    t_body.map(&:reverse).reverse
  ]
end

@presents = presents.map do |present|
  _, *lines = present.split("\n")
  [lines.sum { |l| l.count('#') }, lines]
end


def generate_present_masks
  if @masks.nil?
    # For each possible rotation of the present:
    # Convert pattern 3 bitmasks (one per line of the pattern).
    @masks = arrangements(@presents.map { |_, l| l.map(&:chars)}).map do |arr|
      arr.map { |line| line.inject(0) { |v, c| (v << 1) | (c == '#' ? 1 : 0) } }
    end
    # Remove duplicate arrangements.
    @masks.uniq!
  end
end

def can_fit?(region, c0, c1, c2, c3, c4, c5)
  # TODO (Not needed for the actual input)
  raise NotImplementedError, "Well, this is awkward."
end

@working = 0
regions.split("\n").each do |line|
  case line
  when /\A(\d+)x(\d+):((?:\s+\d+){6})\z/
    width = Regexp.last_match(1).to_i
    height = Regexp.last_match(2).to_i
    counts = Regexp.last_match(3).lstrip.split(/\s+/).map(&:to_i)
    num_presents = counts.sum.to_f
    num_segments = counts.zip(@presents).map { |c, (s, _)| c * s }.sum
    if (width / 3) * (height / 3) >= num_presents
      # At least one 3x3 reserved per present, no arranging needed.
      # (This is all that's needed for the real input.)
      @working += 1
      next
    end
    # If the number of present segments is more than the area, there's no way
    # the presents will fit.
    next if num_segments >= width * height
    generate_present_masks
    @working += 1 if can_fit?([0] * height, *counts)
  else
    raise "Malformed line: '#{line}'"
  end
end

puts "Regions fitting all listed presents: #{@working}"
