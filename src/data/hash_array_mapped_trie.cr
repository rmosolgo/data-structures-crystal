module Data
  # - Trie by object's hash
  # - Handle hash conflicts with a linked list of `Entry` objects
  # - Storage: bitmap + array
  class HashArrayMappedTrie(K, V)
    alias Hash = Int32
    HASH_SIZE = 32 # Treat hashes at 64-bit ints
    INDEX_SIZE = 5 # Use x-bit array indexes (up to 32 entries in the buffer)

    class Entry(K, V)
      property :key, :value, :next
      def initialize(@key : K, @value : V)
      end
    end

    getter :size, :bitmap

    def initialize(@depth = 0)
      @size = 0
      @bitmap = 0_u32
      @buffer = Pointer(self | Entry(K, V)).malloc(@size) # Is this a waste?
    end

    # Store `value` at `key`, overriding the current value if there is one
    def put(key : K, value : V)
      self[key] = value
    end

    def []=(key : K, value : V)
      hash = hash_from_object(key)
      put_at_hash(hash, key, value)
    end

    # If a new key-value is added, this increases the size and returns true
    protected def put_at_hash(hash : Hash, key : K, value : V)
      idx = index_from_hash(hash, @depth)
      idx_mask = 1 << idx
      already_present = (@bitmap & idx_mask) > 0
      storage_idx = popcount(@bitmap, idx)
      if !already_present
        @bitmap |= idx_mask
        @size += 1
        @buffer = @buffer.realloc(@size)
        # eg,
        #   [1, 2, 3, 4, _]
        #        \  \  \
        #   [1, 2, 2, 3, 4]
        from_buffer = @buffer + storage_idx
        to_buffer = from_buffer + 1
        to_buffer.move_from(from_buffer, 1)
        @buffer[storage_idx] = Entry(K, V).new(key, value)
        true
      else
        entry = @buffer[storage_idx]
        if entry.is_a?(Entry(K, V))
          if key == entry.key
            # Same keys. Override the values
            entry.value = value
            return false
          elsif (other_hash = hash_from_object(entry.key)) == hash
            # Same hash, different values. Chain them.
            # Get the last entry in the linked list:
            while entry.next.is_a?(Entry(K, V))
              entry = entry.next as Entry(K, V)
            end
            entry.next = Entry(K, V).new(key, value)
            @size += 1
            true
          else
            # It's a different key, different hash.
            # Make a new trie and add both values.
            new_trie = self.class.new(@depth + 1)
            new_trie.put_at_hash(other_hash, entry.key, entry.value)
            new_trie.put_at_hash(hash, key, value)
            @buffer[storage_idx] = new_trie
            @size += 1
            true
          end
        elsif entry.is_a?(self)
          entry.put_at_hash(hash, key, value) && (@size += 1)
        end
      end
    end

    # Get the value at `key`, raise if not found
    def get(key : K)
      self[key]
    end

    def [](key : K)
      hash = hash_from_object(key)
      entry = entry_at_hash?(hash, key)
      if entry.is_a?(Entry(K, V))
        entry.value
      else
        raise "No such key #{key}"
      end
    end

    # Get the value at `key`, return nil if not found
    def get?(key : K)
      hash = hash_from_object(key)
      entry = entry_at_hash?(hash, key)
      if entry.is_a?(Entry(K, V))
        entry.value
      else
        nil
      end
    end

    # Returns true if the key has a value stored at it
    def contains?(key : K)
      hash = hash_from_object(key)
      !!entry_at_hash?(hash, key)
    end

    # Remove the value at `key`, if there is one. Returns the removed value.
    def delete(key : K)
      hash = hash_from_object(key)
      entry = delete_at_hash(hash, key)
      if entry.is_a?(Entry(K, V))
        entry.value
      else
        nil
      end
    end

    # Returns false if there was no entry
    # Returns the entry if there was one before it was deleted
    def delete_at_hash(hash : Hash, key : K)
      idx = index_from_hash(hash, @depth)
      idx_mask = 1 << idx
      already_present = (@bitmap & idx_mask) > 0
      storage_idx = popcount(@bitmap, idx)
      if !already_present
        false
      else
        entry = @buffer[storage_idx]
        prev_entry = nil
        if entry.is_a?(Entry(K, V))
          while entry
            next_entry = entry.next
            if key == entry.key
              @size -= 1
              if next_entry.is_a?(Entry(K, V))
                # Move the next_entry up the chain
                if prev_entry.is_a?(Entry(K, V))
                  prev_entry.next = next_entry
                else
                  @buffer[storage_idx] = next_entry
                end
              elsif prev_entry.is_a?(Entry(K, V))
                # This entry was the tail, so remove it
                prev_entry.next = nil
              else
                # This was the only entry, clean up the storage
                @bitmap = @bitmap ^ idx_mask
                if storage_idx < @size
                  # [1, 2, 3, 4]
                  #      /  /
                  # [1, 3, 4, 4]
                  from_buffer = @buffer + (storage_idx+1)
                  to_buffer = @buffer + storage_idx
                  subsequent_item_count = @size - storage_idx
                  to_buffer.move_from(from_buffer, subsequent_item_count)
                end
                @buffer = @buffer.realloc(@size)
              end
              return entry
            end
            prev_entry = entry
            entry = next_entry
          end
          false
        elsif entry.is_a?(self)
          removed_entry = entry.delete_at_hash(hash, key)
          if removed_entry
            @size -= 1
          end
          removed_entry
        end
      end
    end

    private def hash_from_object(object)
      object.hash.to_i32
    end

    # get the number of 1s _at or below_ the given bitnumber
    private def popcount(bitmap, bitnumber)
      count = 0
      bitnumber.times { |i| count += bitmap.bit(i) }
      count
    end

    # Get the relevant bits based on depth & index size
    private def index_from_hash(hash : Hash, depth : Int32)
      first_bit = (HASH_SIZE - (@depth * INDEX_SIZE))
      INDEX_SIZE.times.inject(0) do |idx, i|
        bit = hash.bit(first_bit - i)
        idx |= (bit << (INDEX_SIZE - i - 1))
      end
    end

    protected def entry_at_hash?(hash : Hash, key : K)
      idx = index_from_hash(hash, @depth)
      idx_mask = 1 << idx
      already_present = (@bitmap & idx_mask) > 0
      storage_idx = popcount(@bitmap, idx)
      if !already_present
        nil
      else
        entry = @buffer[storage_idx]
        if entry.is_a?(Entry(K, V))
          while entry
            if key == entry.key
              return entry
            end
            entry = entry.next
          end
          nil
        elsif entry.is_a?(self)
          entry.entry_at_hash?(hash, key)
        end
      end
    end
  end
end
