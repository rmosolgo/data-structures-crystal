module Data
  # Stores downcase strings only
  # 🎊
  # Just trying to get the hang of this kind of tree
  class StringArrayMappedTrie
    class Entry
      property :value, :next
      def initialize(@value)
      end
    end

    Buffer = Pointer(self | Entry)
    getter :size

    # This is just so I can be sure it's really working:
    getter :buffer, :bitmap, :depth
    WORD_SIZE = 32 # treat indexes as 32-bit numbers
    INDEX_SIZE = 2 # use first 2 bits for index
    MAX_DEPTH = WORD_SIZE / INDEX_SIZE

    def initialize(@depth = 0)
      @size = 0
      # array idx 3210
      @bitmap = 0b0000
      @buffer = Buffer.malloc(@size)
    end

    def add(word)
      add_hash(hash_from_word(word), word)
    end

    protected def add_hash(hash, word)
      array_index = idx_for_hash(hash)
      present, mask = already_present?(array_index)
      # Which position does this belong in the array?
      stored_offset = popcount(@bitmap, array_index)
      if !present
        @bitmap |= mask
        @size += 1
        @buffer = @buffer.realloc(@size)
        # eg,
        #   [1, 2, 3, 4, _]
        #        \  \  \
        #   [1, 2, 2, 3, 4]
        from_buffer = @buffer + stored_offset
        to_buffer = from_buffer + 1
        to_buffer.move_from(from_buffer, 1)
        @buffer[stored_offset] = Entry.new(word)
        true
      else
        entry = @buffer[stored_offset]
        if entry.is_a?(Entry)
          if entry.value == word # it's already here
            false
          elsif @depth == MAX_DEPTH
            entry.next = Entry.new(word)
            @size += 1
          else
            # time to make a new level
            new_entry = self.class.new(depth: @depth + 1)
            new_entry.add_hash(hash_from_word(entry.value), entry.value)
            new_entry.add_hash(hash, word)
            @buffer[stored_offset] = new_entry
            @size += 1
            true
          end
        elsif entry.is_a?(self)
          was_added = entry.add_hash(hash, word)
          if was_added
            @size += 1
          end
          was_added
        end
      end
    end

    def remove(word)
      remove_hash(hash_from_word(word), word)
    end

    protected def remove_hash(hash, word)
      array_index = idx_for_hash(hash)
      already_present, mask = already_present?(array_index)
      if !already_present
        nil
      else
        stored_offset = popcount(@bitmap, array_index)
        entry = @buffer[stored_offset]
        prev_entry = nil
        if entry.is_a?(Entry)
          while entry
            if entry.value != word
              prev_entry = entry
              entry = entry.next
            else
              # remove from cached size
              @size -= 1
              next_entry = entry.next
              if prev_entry.nil? && next_entry.nil?
                # remove from bitmap
                @bitmap = @bitmap ^ mask
                # remove from storage array
                if stored_offset < @size
                  # [1, 2, 3, 4]
                  #      /  /
                  # [1, 3, 4]
                  from_buffer = @buffer + (stored_offset+1)
                  to_buffer = @buffer + stored_offset
                  subsequent_item_count = @size - stored_offset
                  to_buffer.move_from(from_buffer, subsequent_item_count)
                end
                @buffer = @buffer.realloc(@size)
              elsif next_entry.is_a?(Entry)
                if prev_entry.is_a?(Entry)
                  prev_entry.next = next_entry
                else
                  @buffer[stored_offset] = next_entry
                end
              elsif prev_entry.is_a?(Entry)
                prev_entry.next = nil
              end
              return true
            end
          end
        elsif entry.is_a?(self)
          was_changed = entry.remove_hash(hash, word)
          if was_changed
            @size -= 1
          end
          was_changed
        end
      end
    end

    def contains?(word)
      contains_hash?(hash_from_word(word), word)
    end

    protected def contains_hash?(hash, word)
      array_index = idx_for_hash(hash)
      present, mask = already_present?(array_index)
      if !present
        false
      else
        stored_offset = popcount(@bitmap, array_index)
        entry = @buffer[stored_offset]
        if entry.is_a?(Entry)
          while entry
            if entry.value == word
              return true
            else
              entry = entry.next
            end
          end
          false
        elsif entry.is_a?(self)
          entry.contains_hash?(hash, word)
        end
      end
    end

    def to_a
      array = [] of String
      reduce_values(array)
      array
    end

    protected def reduce_values(acc)
      final_size = acc.size + @size
      buffer_offset = 0
      while acc.size < final_size
        entry = @buffer[buffer_offset]
        if entry.is_a?(Entry)
          while entry
            acc << entry.value
            entry = entry.next
          end
        elsif entry.is_a?(self)
          entry.reduce_values(acc)
        end
        buffer_offset += 1
      end
    end

    # get the number of 1s _below_ the given bitnumber
    private def popcount(bitmap, bitnumber)
      count = 0
      bitnumber.times { |i| count += bitmap.bit(i) }
      count
    end

    # get the part of the hash this object cares about
    private def idx_for_hash(hash)
      first_bit = (WORD_SIZE - (@depth * INDEX_SIZE))
      # this is because INDEX_SIZE is 2, grab the two bits
      idx = (hash.bit(first_bit) << 1) | (hash.bit(first_bit - 1))
      return idx
    end

    private def hash_from_word(word)
      word.each_char.inject(0) { |m, c| m + c.ord }
    end

    private def already_present?(idx)
      idx_mask = 1 << idx
      already_present = (@bitmap & idx_mask) > 0
      {already_present, idx_mask}
    end
  end
end
