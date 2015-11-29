module Data
  # Stores key => value pairs where the key is a lowercased string
  class StringValueTrie(T)
    struct Entry(T)
      getter key, value
      def initialize(@key : String, @value : T)
      end
    end

    getter :size
    def initialize
      @size = 0
      @buffer = Pointer(Nil | self | Entry(T)).malloc(27)
    end

    def get(key)
      entry = find_entry?(key)
      if entry.is_a?(Entry(T))
        entry.value
      else
        raise("Key not found: #{key}")
      end
    end

    def get?(key)
      entry = find_entry?(key)
      if entry.is_a?(Entry(T))
        entry.value
      else
        nil
      end
    end

    def set(key : String, value : T)
      index = index_for_char(key[0]?)
      entry = @buffer[index]
      if entry.nil?
        @buffer[index] = Entry(T).new(key, value)
        @size += 1
        true
      elsif entry.is_a?(self)
        entry.set(key[1..-1], value) && (@size += 1)
      elsif entry.is_a?(Entry(T))
        old_key = entry.key
        if old_key == key
          new_entry = Entry(T).new(key, value)
          @buffer[index] = new_entry
          false
        else
          new_trie = self.class.new
          old_value = entry.value
          new_trie.set(old_key[1..-1], old_value)
          new_trie.set(key[1..-1], value)
          @buffer[index] = new_trie
          @size += 1
          true
        end
      end
    end

    def delete(key)
      deleted, value = delete_entry?(key)
      value
    end

    protected def delete_entry?(key : String)
      index = index_for_char(key[0]?)
      entry = @buffer[index]
      if entry.is_a?(self)
        deleted, value = entry.delete_entry?(key[1..-1])
        if deleted
          @size -= 1 # this is wrong -- what if it's not there?
          {true, value}
        else
          {false, nil}
        end
      elsif entry.is_a?(Entry(T))
        if entry.key == key
          value = entry.value
          @buffer[index] = nil
          @size -= 1
          {true, value}
        else
          {false, nil}
        end
      else
        {false, nil} # wasn't here
      end
    end

    def to_h
      h = {} of String => T
      reduce_keys("", h)
      h
    end

    LETTERS = [nil] + ('a'..'z').to_a
    def each
      to_h.each { |k, v| yield k, v }
    end

    protected def reduce_keys(prefix, acc)
      LETTERS.each do |letter|
        idx = index_for_char(letter)
        entry = @buffer[idx]
        if entry.is_a?(Entry(T))
          key = "#{prefix}#{entry.key}"
          acc[key] = entry.value
        elsif entry.is_a?(self)
          entry.reduce_keys("#{prefix}#{letter}", acc)
        end
      end
    end

    protected def find_entry?(key)
      index = index_for_char(key[0]?)
      entry = @buffer[index]
      if entry.nil?
        nil
      elsif entry.is_a?(T)
        {key, entry}
      elsif entry.is_a?(self)
        entry.find_entry?(key[1..-1])
      elsif entry.is_a?(Entry(T))
        if entry.key == key
          entry
        else
          nil
        end
      end
    end

    private def index_for_char(char : Char)
      char.ord - 96 # 'a'.ord is 97, but we want 1
    end

    private def index_for_char(n : Nil)
      0
    end
  end
end
