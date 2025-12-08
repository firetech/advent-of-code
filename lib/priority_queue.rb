class PriorityQueue
  def initialize(use_linked_queue = false)
    if use_linked_queue
      require_relative 'linked_queue'

      @queue_class = LinkedQueue
    else
      @queue_class = Array
    end
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
      list = @queue[prio]
      if list.nil?
        list = @queue_class.new
        @queue[prio] = list
      end
      list << obj
      @map[obj] = prio
    end
    return prio
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

  def priority(obj)
    @map[obj]
  end

  def size
    @map.size
  end

  def empty?
    @queue.empty?
  end
end
