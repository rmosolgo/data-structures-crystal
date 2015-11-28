module Data
  # Stores downcase strings only
  # 🎊
  # Just trying to get the hang of this kind of tree
  class StringTrie
    getter :size

    # This is just so I can be sure it's really working:
    getter :buffer, :depth

    def initialize(@depth = 0)
      @size = 0
      @buffer = Pointer(self | Nil | String).malloc(27, nil)
    end

    def add(word)
      next_char = word[0]?
      char_idx = index_for_char(next_char)
      subtrie = @buffer[char_idx]

      if subtrie.nil?
        @buffer[char_idx] = next_word(word)
      elsif subtrie.is_a?(self)
        subtrie.add(next_word(word))
      elsif subtrie.is_a?(String)
        new_subtrie = StringTrie.new(@depth + 1)
        new_subtrie.add(subtrie)
        new_subtrie.add(next_word(word))
        @buffer[char_idx] = new_subtrie
      end
      @size += 1
    end

    def remove(word)
      next_char = word[0]?
      char_idx = index_for_char(next_char)
      subtrie = @buffer[char_idx]

      if subtrie.nil?
        return nil # wasn't here in the first place
      elsif subtrie.is_a?(String)
        if subtrie == next_word(word)
          @buffer[char_idx] = nil
        else
          # found a different string
          return nil
        end
      elsif subtrie.is_a?(self)
        subtrie.remove(next_word(word))
      end
      @size -= 1
    end

    def contains?(word)
      next_char = word[0]?
      char_idx = index_for_char(next_char)
      subtrie = @buffer[char_idx]

      if subtrie.nil?
        false
      elsif subtrie.is_a?(String)
        subtrie == next_word(word)
      elsif subtrie.is_a?(self)
        subtrie.contains?(next_word(word))
      end
    end

    def to_a
      array = Array(String).new
      reduce_keys("", array)
      array
    end

    LETTERS = [nil] + ('a'..'z').to_a
    def reduce_keys(prefix, acc)
      LETTERS.each do |char|
        idx = index_for_char(char)
        value = @buffer[idx]
        if value.is_a?(String)
          acc << "#{prefix}#{char}#{value}"
        elsif value.is_a?(self)
          value.reduce_keys("#{prefix}#{char}", acc)
        end
      end
    end

    private def index_for_char(char : Char)
      char.ord - 96 # 'a'.ord is 97, but we want 1
    end

    private def index_for_char(n : Nil)
      0
    end

    private def next_word(word)
      word.size > 0 ? word[1..-1] : word
    end
  end
end
