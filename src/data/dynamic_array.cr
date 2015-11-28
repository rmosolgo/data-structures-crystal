module Data
  class DynamicArray(T)
    include Enumerable(T)
    INITIAL_CAPACITY = 4
    CAPACITY_FACTOR = 2

    getter :size, :capacity

    def initialize(*items)
      @size = 0
      @capacity = INITIAL_CAPACITY
      @buffer = Pointer(T).malloc(@capacity)
      items.map { |i| self.push(i) }
    end

    def at(idx : Int)
      if idx < @size && idx > -1
        @buffer[idx]
      else
        nil
      end
    end

    def set(idx, value : T)
      if idx < @size
        @buffer[idx] = value
      else
        raise("Index out of range (index #{idx} / size #{@size})")
      end
    end

    def delete(idx)
      if idx < @size
        value = @buffer[idx]
        # delete(1)
        # [1, 2, 3, 4]
        #      /  /
        # [1, 3, 4]
        (@buffer + idx).move_from(@buffer + idx + 1, @size - idx)
        @size -= 1
        value
      else
        raise "No value at #{idx} (size: #{@size})"
      end
    end

    # [1, 2, 3].insert(1, 0)  # =>  [1, 0, 2, 3]
    def insert(idx, value : T)
      resize if needs_resize?
      # insert(1, 0)
      # [1, 2, 3, 4]
      #       \  \  \
      # [1, _, 2, 3, 4]
      (@buffer + idx + 1).move_from(@buffer + idx, @size - idx)
      @buffer[idx] = value
      @size += 1
      nil
    end

    def first
      at(0)
    end

    def last
      at(@size - 1)
    end

    def push(value : T)
      resize if needs_resize?
      @buffer[@size] = value
      @size += 1
    end

    def pop
      pop? || raise("No more values")
    end

    def pop?
      if @size > 0
        @size -= 1
        prev_value = @buffer[@size]
        clear_tail
        prev_value
      else
        nil
      end
    end

    def unshift(value : T)
      insert(0, value)
    end

    # remove the first item & return it
    def shift
      shift? || raise("No value to shift")
    end

    def shift?
      if @size == 0
        nil
      else
        value = @buffer[0]
        @size -= 1
        # [1, 2, 3, 4]
        #   /  /  /
        # [2, 3, 4, 4]
        @buffer.copy_from(@buffer + 1, @size)
        clear_tail
        value
      end
    end

    def each
      @size.times do |idx|
        yield @buffer[idx]
      end
    end

    # This implementation is so bad, what's the point?
    # To do it well, you'd want to provide:
    # - A way of initializing an array with a certain capacity
    # - A way to directly move values to its buffer?
    # - (Crystal's array has both of these things)
    def concat(other : self)
      new_list = self.class.new
      self.each { |i| new_list.push(i) }
      other.each { |i| new_list.push(i) }
      new_list
    end


    private def clear_tail
      (@buffer + @size).clear
    end

    private def needs_resize?
      @size == @capacity
    end

    private def resize
      @capacity = @capacity * CAPACITY_FACTOR
      @buffer = @buffer.realloc(@capacity)
    end
  end
end
