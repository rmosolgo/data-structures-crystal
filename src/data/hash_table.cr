module Data
  class HashTable(K, V)
    INITIAL_CAPACITY = 11
    LINKS_PER_SLOT = 5
    getter size, slots_count

    def initialize
      @size = 0
      @slots_count = INITIAL_CAPACITY
      @slots = get_slots(@slots_count)
    end

    def get(key)
      entry = find_entry?(key)
      if entry.is_a?(Entry)
        entry.value
      else
        raise("Key not found: #{key}")
      end
    end

    def get?(key)
      find_entry?(key).try(&.value)
    end

    def put(key, value)
      if needs_rehash?
        rehash
      end

      idx = slot_index_for_key(key)
      put_in_slot(idx, key, value)
      value
    end

    def delete(key)
      idx = slot_index_for_key(key)
      entry = @slots[idx]
      value = nil
      previous_entry = nil
      if entry
        while entry
          if entry.key == key
            @size -= 1
            # patch up the linked list or move the next to first position
            if previous_entry
              previous_entry.next = entry.next
            else
              @slots[idx] = entry.next
            end
            value = entry.value
            break
          end
          previous_entry = entry
          entry = entry.next
        end
      end

      entry.try(&.value)
    end

    private def slot_index_for_key(key)
      key.hash.abs % @slots_count
    end

    private def put_in_slot(index, key, value)
      entry = @slots[index]
      if entry
        while entry
          if entry.key == key
            entry.value = value
            return
          elsif entry.next
            entry = entry.next
          else
            entry.next = Entry(K, V).new(key, value)
            @size += 1
            return
          end
        end
      else
        @slots[index] = Entry(K, V).new(key, value)
        @size += 1
      end
    end

    private def find_entry?(key)
      idx = slot_index_for_key(key)
      entry = @slots[idx]
      if entry
        while entry
          if entry.key == key
            break
          end
          entry = entry.next
        end
      end
      entry
    end

    private def needs_rehash?
      @size > (@slots_count * LINKS_PER_SLOT)
    end

    # Crystal's hash takes advantage of its ordered-ness
    # to optimize the rehash. Meh.
    private def rehash
      old_slots_count = @slots_count
      old_slots = @slots
      # I think there are better resize patterns. Meh.
      @slots_count = @slots_count * 2
      # Allocate some more memory, then rewrite yourself into that memory.
      @slots = get_slots(@slots_count)
      @size = 0
      old_slots_count.times do |slot|
        entry = old_slots[slot]
        while entry
          self.put(entry.key, entry.value)
          entry = entry.next
        end
      end
    end

    private def get_slots(slots_count)
      Pointer(Entry(K, V)?).malloc(slots_count)
    end

    # A key-value pair
    # A member of linked-list, in case of collisions
    class Entry(K, V)
      property :key, :value, :next
      def initialize(@key, @value)
      end
    end
  end
end
