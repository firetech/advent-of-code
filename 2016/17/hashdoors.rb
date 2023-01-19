require 'digest/md5'
require_relative '../../lib/aoc'

input = ARGV[0] || AOC.input()
#input = 'ihgpwlah'
#input = 'kglvqrro'
#input = 'ulqzkmiv'

DIRS = {
  'U' => [  0, -1 ],
  'D' => [  0,  1 ],
  'L' => [ -1,  0 ],
  'R' => [  1,  0 ]
}

queue = [ [ 0, 0, '' ] ]
min_path = nil
path_lengths = []
while not queue.empty?
  x, y, path = queue.shift
  hash = Digest::MD5.hexdigest(input + path)
  DIRS.each_with_index do |(dir, (dx, dy)), i|
    px, py = x + dx, y + dy
    if hash[i].between?('b', 'f') and px.between?(0, 3) and py.between?(0, 3)
      if px == 3 and py == 3
        if min_path.nil?
          min_path = path + dir
          puts "Shortest path: #{min_path}" # Part 1
        end
        path_lengths << path.length + 1
      else
        queue << [ px, py, path + dir ]
      end
    end
  end
end

puts "Longest path: #{path_lengths.max} steps" # Part 2
