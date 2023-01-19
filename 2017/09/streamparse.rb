require_relative '../../lib/aoc'

input = File.read(ARGV[0] || AOC.input_file()).strip
#input = '{}'
#input = '{{{}}}'
#input = '{{},{}}'
#input = '{{{},{},{{}}}}'
#input = '{<a>,<a>,<a>,<a>}'
#input = '{{<ab>},{<ab>},{<ab>},{<ab>}}'
#input = '{{<!!>},{<!!>},{<!!>},{<!!>}}'
#input = '{{<a!>},{<a!>},{<a!>},{<ab>}}'

def parse_group(stream, offset = 1, level = 1)
  score = level
  garbage = 0
  while offset < stream.length
    case stream[offset]
    when '{'
      grp_score, grp_garbage, offset = parse_group(stream, offset+1, level+1)
      score += grp_score
      garbage += grp_garbage
    when '}'
      return score, garbage, offset+1
    when '<'
      offset, size = parse_garbage(stream, offset+1)
      garbage += size
    when ','
      offset += 1
    else
      raise "Unexpected character in group: '#{stream[offset]}' (@#{offset})"
    end
  end
  raise "Stream ended mid-group"
end

def parse_garbage(stream, offset = 1)
  count = 0
  while offset < stream.length
    case stream[offset]
    when '!'
      offset += 1
    when '>'
      return offset+1, count
    else
      count += 1
    end
    offset += 1
  end
  raise "Stream ended mid-garbage"
end

stream = input.chars
if stream.first != '{'
  raise "Expected '{' at start of input"
end

score, garbage, offset = parse_group(stream, 1)
if offset < stream.length
  raise "Outer group ended before stream"
end

# Part 1
puts "Total score: #{score}"

# Part 2
puts "Garbage characters: #{garbage}"
