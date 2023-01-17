require_relative '../../lib/aoc_api'
require_relative '../lib/intcode'

input = File.read(ARGV[0] || AOC.input_file()).strip

VERBOSE = false

CHECKPOINT = 'Security Checkpoint'
IGNORE_ITEMS = [
  'giant electromagnet',
  'escape pod',
  'molten lava',
  'photons',
  'infinite loop'
]
REVERSE_OF = {
  'north' => 'south',
  'south' => 'north',
  'east' => 'west',
  'west' => 'east'
}

@droid = Intcode.new(input, false)

@map = {}
@path_to_checkpoint = nil
@items = []

def cmd(str)
  puts str if VERBOSE
  str.each_char { |c| @droid << c.ord }
  @droid << "\n".ord
  Thread.pass until @droid.has_output?
  Thread.pass until @droid.waiting_for_input? or not @droid.running?
end

def get_output
  output = ''
  while @droid.has_output?
    chr = @droid.output.chr
    print chr if VERBOSE
    output << chr
  end
  return output
end

def parse_output(output = nil)
  output = get_output if output.nil?

  list = :none
  room = nil
  directions = []
  items = []
  output.split("\n").each do |line|
    case line
    when /\A== (.*) ==\z/
      room = Regexp.last_match[1]
    when /\ADoors here lead:\z/
      list = :directions
    when /\AItems here:\z/
      list = :items
    when /\A\s*\z/
      list = :none
    when /\A- (.*)\z/
      case list
      when :directions
        directions << Regexp.last_match[1]
      when :items
        items << Regexp.last_match[1]
      else
        raise "Unexpected list content: #{line}"
      end
    end
  end

  return room, directions, items
end

def search(last_room = nil, path = [])
  room, directions, items = parse_output

  unless @map.has_key?(room)
    room_map = {}
    directions.each do |dir|
      room_map[dir] = nil
    end
    @map[room] = room_map
  end
  if last_room.nil?
    @map[:entry] = room
  else
    @map[last_room][path.last] = room
    @map[room][REVERSE_OF[path.last]] = last_room
  end

  items.each do |item|
    unless IGNORE_ITEMS.include?(item)
      cmd("take #{item}")
      @items << item
      get_output
    end
  end

  if room == CHECKPOINT
    @path_to_checkpoint = path
  else
    directions.each do |dir|
      if @map[room][dir].nil?
        cmd(dir)
        search(room, path + [dir])
        cmd(REVERSE_OF[dir])
        new_room, _, _ = parse_output
        if new_room != room
          raise "Expected '#{room}', got '#{new_room}'"
        end
      end
    end
  end
end

begin
  @thread = Thread.new { @droid.run }
  Thread.pass while not @droid.running?
  puts '### Searching ship...'
  search
  puts '### Moving to checkpoint...'
  room = @map[:entry]
  @path_to_checkpoint.each do |dir|
    cmd(dir)
    new_room, _, _ = parse_output
    if new_room != @map[room][dir]
      raise "Expected '#{@map[room][dir]}', got '#{new_room}'"
    end
    room = new_room
  end
  if room != CHECKPOINT
    raise "Expected '#{CHECKPOINT}', got '#{room}'"
  end
  check_dir = nil
  @map[room].each do |dir, to|
    if to.nil?
      check_dir = dir
      break
    end
  end
  raise "Don't know where to go..." if check_dir.nil?

  # Generate a somewhat optimal order of combination sizes
  val = @items.count / 2
  order = [ val ]
  min = val - 1
  max = val + 1
  while min >= 1 or max <= @items.count
    order << min if min >= 1
    order << max if max <= @items.count
    min -= 1
    max += 1
  end

  current = @items
  done = false
  order.each do |n|
    @items.combination(n) do |list|
      puts "### Trying #{list.join (', ')}..."
      (current - list).each do |drop_item|
        cmd("drop #{drop_item}")
        get_output
      end
      (list - current).each do |take_item|
        cmd("take #{take_item}")
        get_output
      end
      current = list
      cmd(check_dir)
      output = get_output
      room, _, _ = parse_output(output)
      if room != CHECKPOINT
        puts output unless VERBOSE
        done = true
        break
      end
    end
    break if done
  end

  raise "Nothing worked :(" unless done
ensure
  @thread.kill
end
