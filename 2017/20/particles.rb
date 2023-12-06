require_relative '../../lib/aoc'
require_relative '../../lib/aoc_math'

file = ARGV[0] || AOC.input_file()
#file = 'example1'
#file = 'example2'

COORDS = /-?\d+,-?\d+,-?\d+/
@particles = {}
File.read(file).strip.split("\n").each_with_index do |line, i|
  if line =~ /\Ap=<(#{COORDS})>, v=<(#{COORDS})>, a=<(#{COORDS})>\z/
    _, pos_s, vel_s, acc_s = Regexp.last_match.to_a
    pos, vel, acc = [pos_s, vel_s, acc_s].map { |s| s.split(',').map(&:to_i) }
    @particles[i] = pos.zip(vel, acc).map do |p, v, a|
      # Convert each axis to a function of time, p(t):
      #
      # p(1) = p + v+a                                (v(1) = v+a)
      #      = p + 1v + 1a
      # p(2) = p + v+a + v+a+a                        (v(2) = v+a+a)
      #      = p + 2v + 3a
      # p(3) = p + v+a + v+a+a + v+a+a+a              (v(3) = v+a+a+a)
      #      = p + 3v + 6a
      # p(4) = p + v+a + v+a+a + v+a+a+a + v+a+a+a+a  (v(4) = v+a+a+a+a)
      #      = p + 4v + 10a
      # p(5) = p + v+a + v+a+a + v+a+a+a + v+a+a+a+a + v+a+a+a+a+a
      #      = p + 5v + 15a
      #            ^=t   ^=t*(t+1)/2 (https://oeis.org/A000217)
      #
      # p(t) = p + t*v + (t*(t+1)/2)*a
      # p(t) = p + t*v + ((t*t+t)/2)*a
      # p(t) = p + t*v + (t*t/2)*a + (t/2)*a
      # p(t) = p + t*v + t*a/2 + t*t*a/2
      # p(t) = p + t*(v + a/2) + t*t*(a/2)
      # p(t) = (a/2)*t^2 + (v + a/2)*t + p
      [        a/2.0,       v + a/2.0,   p ]
    end
  else
    raise "Malformed line: '#{line}'"
  end
end

################################################################################
# Part 1

# Boring solution, but the absolute value part of Manhattan distance calculation
# makes this a bit hard to analyze properly. Just find find closest particle
# after 1.000 ticks.
particle_dists = @particles.map do |i, funcs|
  [i, funcs.map { |a, b, c| (a*1000*1000 + b*1000 + c).abs }.sum]
end
closest = particle_dists.min_by(&:last).first
puts "Closest particle in long term: #{closest}"

################################################################################
# Part 2

collisions = {}
@particles.keys.combination(2) do |i_1,i_2|
  p_1 = @particles[i_1]
  p_2 = @particles[i_2]

  p_collisions = nil
  p_1.zip(p_2) do |(a_1, b_1, c_1), (a_2, b_2, c_2)|
    # a_1*t^2 + b_1*t + c_1 = a_2*t^2 + b_2*t + c_2
    # a_1*t^2 + b_1*t + c_1 - (a_2*t^2 + b_2*t + c_2) = 0
    # a_1*t^2 + b_1*t + c_1 - a_2*t^2 - b_2*t - c_2 = 0
    # (a_1-a_2)*t^2 + (b_1-b_2)*t + (c_1-c_2) = 0
    axis_collisions = AOCMath.quadratic_solutions(a_1-a_2, b_1-b_2, c_1-c_2)
    next if axis_collisions.nil?
    # Filter integer results (accounting for rounding errors)
    axis_collisions.select! { |x| x > 0 and (x - x.round).abs < 1e-5 }
    axis_collisions.map!(&:round)
    if p_collisions.nil?
      p_collisions = axis_collisions
    else
      p_collisions &= axis_collisions
    end
    break if p_collisions.empty?
  end
  next if p_collisions.nil?
  p_collisions.each do |t|
    collisions[i_1] ||= []
    collisions[i_1] << [i_2, t]
    collisions[i_2] ||= []
    collisions[i_2] << [i_1, t]
  end
end

# Sort collisions by lowest time and transform collision list to grouped hash
collisions.transform_values! do |list|
  list.group_by { |i, t| t }.sort_by { |k, v| k }.to_h.transform_values do |v|
    v.map(&:first)
  end
end
collisions = collisions.sort_by { |i, list| list.keys.first }.to_h

removed_at = {}
collisions.each do |i, groups|
  next if removed_at.has_key?(i)
  groups.each do |t, list|
    left = list.select do |i_l|
      not removed_at.has_key?(i_l) or removed_at[i_l] < t
    end
    if not left.empty?
      removed_at[i] = t
      list.each { |i_l| removed_at[i_l] = t }
      break
    end
  end
end

puts "Particles left after collisions: #{@particles.length - removed_at.length}"
