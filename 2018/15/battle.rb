require 'set'

file = 'input'
#file = 'move_example1'
#file = 'move_example2'
#file = 'move_example3'
#file = 'full_example1'
#file = 'full_example2'
#file = 'full_example3'

MOVES = [[0, -1], [-1, 0], [1, 0], [0, 1]]
BASE_ATK = 3
HP = 200
VISUAL_BASE_FIGHT = true

class Entity
  attr_reader :x, :y, :hp, :team

  def initialize(x, y, team)
    @x = x
    @y = y
    @hp = HP
    @team = team
  end

  def move(map, entities)
    enemies = entities.select { |e| e.team != @team }
    if enemies.empty?
      return nil
    end
    map_width = map.first.length
    reachable = Set[]
    enemies.each do |e|
      MOVES.each do |delta_x, delta_y|
        px = e.x + delta_x
        py = e.y + delta_y
        if @x == px and @y == py
          # In reach of target, don't move
          return true
        elsif (map[py] or [])[px] == '.' and
            entities.none? { |oe| oe.x == px and oe.y == py }
          reachable << [px, py]
        end
      end
    end
    targets = reachable.sort_by { |px, py| (@x - px).abs + (@y - py).abs }

    queue = [[@x, @y, []]]
    found_paths = Set[]
    all_paths_found = false
    visited = Set[]
    until queue.empty? or all_paths_found
      fx, fy, path = queue.shift
      break if not found_paths.empty? and path.length > found_paths.first.first
      f = [fx, fy]
      next if visited.include?(f)
      visited << f
      MOVES.each do |delta_x, delta_y|
        px = fx + delta_x
        py = fy + delta_y
        p = [px, py]
        p_path = path + [p]
        if targets.include?(p)
          found_paths << [ p_path.length, p_path.first ]
        else
          if (map[py] or [])[px] == '.' and
              entities.none? { |oe| oe.x == px and oe.y == py }
            queue << [px, py, p_path]
          end
        end
      end
    end
    if found_paths.empty?
      return false
    end
    min_length = found_paths.map(&:first).min
    min_paths = found_paths.select { |l, _| l == min_length }
    @x, @y = min_paths.map(&:last).min_by { |x, y| y * map_width + x }
    return targets.include?([@x, @y])
  end

  def attack(map, entities, atk = BASE_ATK)
    close_enemies = entities.select do |e|
      e.team != @team and (@x - e.x).abs + (@y - e.y).abs == 1
    end
    if close_enemies.empty?
      return
    end
    map_width = map.first.length
    target = close_enemies.sort_by { |e| e.y * map_width + e.x }.min_by(&:hp)
    target.hp -= atk
  end

  protected
  attr_writer :hp
end

def print_map(entities = [])
  map_str = @map.map.with_index do |line, y|
    line_str = line.map.with_index do |c, x|
      entity = entities.find { |e| e.x == x and e.y == y }
      if entity.nil?
        c
      else
        entity.team
      end
    end
    line_str.join
  end
  puts map_str.join("\n")
end

@entities = []
@map = File.read(file).strip.split("\n").map.with_index do |line, y|
  line.chars.map.with_index do |c, x|
    case c
    when 'E', 'G'
      @entities << Entity.new(x, y, c)
      '.'
    else
      c
    end
  end
end
@width = @map.first.length

def fight(elf_power = BASE_ATK, base_fight = true)
  entities = @entities.map(&:clone)
  continue = true
  complete_rounds = 0
  power = { 'E' => elf_power, 'G' => BASE_ATK }
  while continue
    entities.sort_by { |e| e.y * @width + e.x }.each do |e|
      next if e.hp <= 0
      result = e.move(@map, entities)
      if result.nil?
        continue = false
        break
      elsif result
        e.attack(@map, entities, power[e.team])
        entities.select! do |e|
          alive = e.hp > 0
          if not base_fight and not alive and e.team == 'E'
            puts "Elf died in round #{complete_rounds + 1}"
            return false, nil
          end
          alive
        end
      end
    end
    if VISUAL_BASE_FIGHT and base_fight
      puts
      print_map(entities)
    end
    if continue
      complete_rounds += 1
    end
  end
  winners = entities.first.team
  outcome = complete_rounds * entities.map(&:hp).sum
  puts '%s win in %d rounds, outcome: %d' % [
    { 'E' => 'Elves', 'G' => 'Goblins' }[winners],
    complete_rounds,
    outcome
  ]
  return winners == 'E', entities, outcome
end

# Part 1
puts 'Simulating base fight...'
fight

# Part 2
puts
puts 'Searching for minimum elf power for full survival...'
results = {}
min_power = (BASE_ATK+1..HP).bsearch do |p|
  print "Attack power #{p}: "
  win, entities, outcome = fight(p, false)
  results[p] = outcome
  win
end
puts
puts "Minimum survival power is #{min_power}, outcome: #{results[min_power]}"
