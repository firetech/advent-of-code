require 'set'

file = 'input'
#file = 'example1'
#file = 'example2'
#file = 'example3'

class Cuboid
  attr_reader :x_min, :x_max, :y_min, :y_max, :z_min, :z_max
  def initialize(x_min, x_max, y_min, y_max, z_min, z_max)
    @x_min = x_min
    @x_max = x_max
    @y_min = y_min
    @y_max = y_max
    @z_min = z_min
    @z_max = z_max
  end

  def intersects?(other)
    return ([@x_min, other.x_min].max < [@x_max, other.x_max].min and
        [@y_min, other.y_min].max < [@y_max, other.y_max].min and
        [@z_min, other.z_min].max < [@z_max, other.z_max].min)
  end

  def intersection(other)
    return nil unless intersects?(other)
    return Cuboid.new(
      [@x_min, other.x_min].max,
      [@x_max, other.x_max].min,
      [@y_min, other.y_min].max,
      [@y_max, other.y_max].min,
      [@z_min, other.z_min].max,
      [@z_max, other.z_max].min
    )
  end

  def slice_with(other)
    return [] unless intersects?(other)
    # Generate the list of sub-cuboids created by slicing each two cuboids along
    # each of the other's boundaries.
    # I.e. (in two dimensions, # = Overlap)
    #   222       112
    # 11##2  => 33445
    # 11##2     33445
    # 1111      6677
    slices = []
    xs = [@x_min, other.x_min, @x_max, other.x_max].uniq.sort
    ys = [@y_min, other.y_min, @y_max, other.y_max].uniq.sort
    zs = [@z_min, other.z_min, @z_max, other.z_max].uniq.sort
    xs.each_cons(2) do |s_x_min, s_x_max|
      ys.each_cons(2) do |s_y_min, s_y_max|
        zs.each_cons(2) do |s_z_min, s_z_max|
          slices << Cuboid.new(
            s_x_min, s_x_max,
            s_y_min, s_y_max,
            s_z_min, s_z_max
          )
        end
      end
    end
    return slices
  end

  def size
    (@x_max - @x_min) * (@y_max - @y_min) * (@z_max - @z_min)
  end

  def hash
    [@x_min, @x_max, @y_min, @y_max, @z_min, @z_max].hash
  end

  def eql?(other)
    return (other.is_a?(Cuboid) and
        @x_min == other.x_min and @x_max == other.x_max and
        @y_min == other.y_min and @y_max == other.y_max and
        @z_min == other.z_min and @z_max == other.z_max)
  end
end

@cuboids = []
File.read(file).strip.split("\n").each do |line|
  case line
  when /\A(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)\z/
    @cuboids << [
      Regexp.last_match(1) == 'on',
      Cuboid.new(
        Regexp.last_match(2).to_i,
        Regexp.last_match(3).to_i + 1,  # Input is inclusive, Cuboid is not.
        Regexp.last_match(4).to_i,
        Regexp.last_match(5).to_i + 1,  # Ditto.
        Regexp.last_match(6).to_i,
        Regexp.last_match(7).to_i + 1   # ...and ditto.
      )
    ]
  else
    raise "Malformed line: '#{line}'"
  end
end

def reboot_reactor(boundary = nil)
  on_cuboids = Set[]
  @cuboids.each do |on, input_cuboid|
    target_cuboid = input_cuboid
    unless boundary.nil?
      target_cuboid = boundary.intersection(target_cuboid)
      next if target_cuboid.nil?
    end
    on_cuboids.to_a.each do |cuboid| # .to_a is cheap clone (for modification)
      # Slice up intersection into smaller cuboids, add all slices that only
      # intersect with the old cuboid
      slices = cuboid.slice_with(target_cuboid)
      next if slices.empty?
      on_cuboids.delete(cuboid)
      slices.each do |slice|
        if cuboid.intersects?(slice) and not target_cuboid.intersects?(slice)
          on_cuboids << slice
        end
      end
    end
    on_cuboids << target_cuboid if on
  end
  return on_cuboids.sum(&:size)
end

# Part 1
# Since the upper limit is not exclusive, we need to use 51 instead of 50 here.
part1_on = reboot_reactor(Cuboid.new(-50, 51, -50, 51, -50, 51))
puts "Cubes on in initialization region: #{part1_on}"

# Part 2
part2_on = reboot_reactor
puts "Cubes on in entire space: #{part2_on}"
