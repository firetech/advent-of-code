begin
  require 'd_heap'
  HAS_D_HEAP = true
rescue LoadError
  HAS_D_HEAP = false
end


class NativePriorityQueue
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
  alias_method :rescore, :push
  alias_method :[]=, :push

  def peek
    return nil if empty?
    @queue[@queue.keys.min].first
  end

  def pop
    return nil if empty?
    prio = @queue.keys.min
    list = @queue[prio]
    obj = list.shift
    @queue.delete(prio) if list.empty?
    @map.delete(obj)
    return obj
  end

  def pop_below(max_score)
    return pop if not empty? and @queue.keys.min < max_score
    nil
  end

  def score(obj)
    @map[obj]
  end
  alias_method :[], :score

  def clear
    @queue.clear
    @map.clear
  end

  def empty?
    @queue.empty?
  end

  def size
    @map.size
  end
end

# Adapter for using DHeap::Map as a slot-in replacement, if it's available.
# Otherwise, fall back to NativePriorityQueue above.
module PriorityQueue
  def self.new(use_dheap_if_available = true, use_linked_queue = false)
    if HAS_D_HEAP and use_dheap_if_available and not use_linked_queue
      return DHeap::Map.new
    end
    return NativePriorityQueue.new(use_linked_queue)
  end
end
