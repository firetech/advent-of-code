class LinkedQueue
  def initialize
    @head = nil
    @tail = nil
    @prev = {}
    @next = {}
  end

  def push(obj)
    raise ArgumentError, "Duplicate value" if @prev.has_key?(obj)
    @prev[obj] = @tail
    @next[obj] = nil
    if @head.nil?
      @head = obj
    else
      @next[@tail] = obj
    end
    @tail = obj
  end
  alias_method :<<, :push

  def first
    @head
  end

  def shift
    return nil if @head.nil?

    obj = @head
    @head = @next.delete(obj)
    @prev.delete(obj)
    @tail = nil if @head.nil?

    return obj
  end

  def delete(obj)
    obj_next = @next.delete(obj)
    return nil if obj_next.nil?
    obj_prev = @prev.delete(obj)

    if @head == obj
      @head = obj_next
      @tail = nil if @head.nil?
    elsif @tail == obj
      @tail = obj_prev
      @next[@tail] = nil
    else
      @next[obj_prev] = obj_next
      @prev[obj_next] = obj_prev
    end

    return obj
  end

  def empty?
    return @head.nil?
  end
end
