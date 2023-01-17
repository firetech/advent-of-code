require_relative '../../lib/aoc_api'

input = File.read(ARGV[0] || AOC.input_file()).strip
#input = 'ne,ne,ne'
#input = 'se,sw,se,sw,sw'

def neighbour(q, r, dir)
  # For explanation, see https://www.redblobgames.com/grids/hexagons/#coordinates-axial
  case dir
  when 'ne'
    q += 1
    r -= 1
  when 'n'
    r -= 1
  when 'nw'
    q -= 1
  when 'sw'
    q -= 1
    r += 1
  when 's'
    r += 1
  when 'se'
    q += 1
  else
    raise "Unknown dir: '#{dir}'"
  end
  return q, r
end

def distance(aq, ar, bq, br)
  return ((aq - bq).abs + (aq + ar - bq - br).abs + (ar - br).abs) / 2
end

pos = [0, 0]
max_dist = 0
input.split(',').each do |step|
  pos = neighbour(*pos, step)
  max_dist = [distance(0, 0, *pos), max_dist].max
end

# Part 1
puts "Distance from start to end: #{distance(0, 0, *pos)}"

# Part 2
puts "Maximum distance: #{max_dist}"
