class PriorityQueue
  def initialize
    @queue = {}
    @map = {}
  end

  def push(obj, prio)
    current_prio = @map[obj]
    if current_prio != prio
      unless current_prio.nil?
        list = @queue[current_prio]
        list.delete(obj)
        @queue.delete(current_prio) if list.empty?
      end
      @queue[prio] ||= []
      @queue[prio] << obj
      @map[obj] = prio
    end
  end

  def pop_min
    pop(@queue.keys.min)
  end

  def pop_max
    pop(@queue.keys.max)
  end

  def priorities
    @queue.keys
  end

  def pop(prio)
    list = @queue[prio]
    obj = list.shift
    @queue.delete(prio) if list.empty?
    @map.delete(obj)
    return obj
  end

  def size
    @queue.map { |_, l| l.size }.sum
  end

  def empty?
    @queue.empty?
  end
end
