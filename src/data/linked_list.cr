module Data
  class LinkedList(T)
    include Enumerable(T)
    class Node
      property :next, :prev, :value
      def initialize(@value, @next, @prev)
      end
    end

    getter size

    def initialize(*items)
      @size = 0
      @first_node = nil
      @last_node = nil
      items.each { |i| self.push(i) }
    end

    def push(value : T)
      current_last = @last_node
      node = Node.new(value, nil, current_last)
      if current_last.is_a?(Node)
        current_last.next = node
      end
      @last_node = node
      adjust_size(1)
      nil
    end

    def pop
      pop? || raise("No value to pop")
    end

    def pop?
      current_last = @last_node
      if current_last.is_a?(Node)
        @last_node = current_last.prev
        adjust_size(-1)
        return current_last.value
      else
        return nil
      end
    end

    def unshift(value : T)
      current_first = @first_node
      new_first = Node.new(value, current_first, nil)
      if current_first.is_a?(Node)
        current_first.prev = new_first
      end
      @first_node = new_first
      adjust_size(1)
      nil
    end

    def shift
      shift? || raise("No value to shift!")
    end

    def shift?
      current_first = @first_node
      if current_first.is_a?(Node)
        @first_node = current_first.next
        adjust_size(-1)
        return current_first.value
      else
        return nil
      end
    end

    def last
      @last_node.try(&.value)
    end

    def first
      @first_node.try(&.value)
    end

    def at(idx)
      node_at(idx).value
    end

    def set(idx, value : T)
      node_at(idx).value = value
      nil
    end

    def insert(before_idx, value : T)
      next_node = node_at?(before_idx)
      prev_node = next_node.try(&.prev)
      new_node = Node.new(value, next_node, prev_node)
      if next_node.is_a?(Node)
        next_node.prev = new_node
      end
      if next_node == @first_node
        @first_node = new_node
      end

      if prev_node.is_a?(Node)
        prev_node.next = new_node
      end
      if prev_node == @last_node
        @last_node = new_node
      end

      adjust_size(1)
      nil
    end

    def delete(idx)
      existing_node = node_at(idx)
      value = existing_node.value
      prev_node = existing_node.prev
      next_node = existing_node.next
      if prev_node.is_a?(Node)
        prev_node.next = next_node
      else
        @first_node = next_node
      end

      if next_node.is_a?(Node)
        next_node.prev = prev_node
      else
        @last_node = prev_node
      end

      adjust_size(-1)
      value
    end

    def each
      node = @first_node
      while node.is_a?(Node)
        yield node.value as T
        node = node.next
      end
    end

    private def adjust_size(change)
      @size += change
      if @size == 0
        @first_node = nil
        @last_node = nil
      end
      if @size == 1
        only_node = @first_node || @last_node
        @first_node = only_node
        @last_node = only_node
      end
    end

    private def node_at?(idx)
      node = @first_node
      idx.times {
        if node.is_a?(Node)
          node = node.next
        else
          return nil
        end
      }
      node
    end

    private def node_at(idx)
      node = node_at?(idx)
      if node.is_a?(Node)
        node
      else
        raise("Index out of range (index: #{idx}, size: #{@size})")
      end
    end
  end
end
