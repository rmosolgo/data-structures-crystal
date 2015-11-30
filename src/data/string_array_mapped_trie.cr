module Data
  # Stores downcase strings only
  # 🎊
  # Just trying to get the hang of this kind of tree
  class StringArrayMappedTrie
    Buffer = Pointer(self | Int32)
    getter :size

    # This is just so I can be sure it's really working:
    getter :buffer, :bitmap, :depth
    WORD_SIZE = 32 # treat indexes as 32-bit numbers
    INDEX_SIZE = 2 # use first 2 bits for index

    def initialize(@depth = 0)
      @size = 0
      # array idx 3210
      @bitmap = 0b0000
      @buffer = Buffer.malloc(@size)
    end

    def add(word)
      add_hash(hash_from_word(word))
      nil
    end

    protected def add_hash(hash)
      array_index = idx_for_hash(hash)
      array_index_map = 1 << array_index
      already_present = (@bitmap & array_index_map) > 0
      @bitmap |= array_index_map
      # ^ eg, 0b0001 => 0b0101
      # Which position does this belong in the array?
      stored_offset = popcount(@bitmap, array_index)
      if !already_present
        # puts "INT #{hash} #{@depth}"
        add_entry(stored_offset, hash)
        true
      else
        entry = @buffer[stored_offset]
        if entry.is_a?(Int32)
          if entry == hash
            false
          else
            new_entry = self.class.new(depth: @depth + 1)
            # puts "New entry #{hash} + #{entry} (#{@depth} -> #{@depth+1})"
            new_entry.add_hash(entry)
            new_entry.add_hash(hash)
            @buffer[stored_offset] = new_entry
            @size += 1
            true
          end
        elsif entry.is_a?(self)
          was_added = entry.add_hash(hash)
          if was_added
            @size += 1
          end
          was_added
        end
      end
    end

    def remove(word)
      remove_hash(hash_from_word(word))
    end

    protected def remove_hash(hash)
      array_index = idx_for_hash(hash)
      array_index_map = 1 << array_index
      already_present = (@bitmap & array_index_map) > 0
      if !already_present
        nil
      else
        stored_offset = popcount(@bitmap, array_index)
        entry = @buffer[stored_offset]
        if entry.is_a?(Int32)
          if entry == hash
            # remove from bitmap
            @bitmap = @bitmap ^ array_index_map
            # remove from cached size
            @size -= 1
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
            true
          else
            # something else was here
            nil
          end
        elsif entry.is_a?(self)
          entry.remove_hash(hash) && (@size -= 1)
        end
      end
    end

    def contains?(word)
      contains_hash?(hash_from_word(word))
    end

    protected def contains_hash?(hash)
      array_index = idx_for_hash(hash)
      array_index_map = 1 << array_index
      already_present = (@bitmap & array_index_map) > 0
      if !already_present
        false
      else
        stored_offset = popcount(@bitmap, array_index)
        entry = @buffer[stored_offset]
        if entry.is_a?(Int32)
          entry == hash
        elsif entry.is_a?(self)
          entry.contains_hash?(hash)
        end
      end
    end

    def to_a
      [] of String
    end

    # get the number of 1s _below_ the given bitnumber
    private def popcount(bitmap, bitnumber)
      count = 0
      bitnumber.times { |i| count += bitmap.bit(i) }
      count
    end

    # get an entry at `idx`, inserting if necessary
    private def add_entry(idx, hash)
      @size += 1
      @buffer = @buffer.realloc(@size)
      # eg,
      #   [1, 2, 3, 4, _]
      #        \  \  \
      #   [1, 2, 2, 3, 4]
      from_buffer = @buffer + idx
      to_buffer = from_buffer + 1
      to_buffer.move_from(from_buffer, 1)
      @buffer[idx] = hash
    end

    # get the part of the hash this object cares about
    private def idx_for_hash(hash)
      # clear the front
      if @depth == 0
        # 1 << 32 is zero because wrap-around
        idx = hash >> (WORD_SIZE - INDEX_SIZE)
      else
        first_bit = (WORD_SIZE - (@depth * INDEX_SIZE))
        # clear the upper bits
        idx = (hash % (1 << first_bit))
        # then shift away the lower bits
        idx = idx >> (first_bit - 2)
      end
      idx
    end

    private def hash_from_word(word)
      word.each_char.inject(0) { |m, c| m + c.ord }
    end
  end
end
