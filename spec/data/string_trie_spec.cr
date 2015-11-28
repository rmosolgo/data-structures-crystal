require "../spec_helper"

describe "StringTrie" do
  describe "#add / #remove" do
    it "adds and removes elements" do
      trie = Data::StringTrie.new

      trie.add("crystal")
      trie.add("ruby")
      trie.add("rudy")
      trie.add("elixir")

      trie.size.should eq(4)

      trie.remove("ruby")
      trie.remove("elixir")
      trie.size.should eq(2)
    end
  end

  describe "#contains?" do
    it "tells membership" do
      trie = Data::StringTrie.new
      trie.contains?("crystal").should eq(false)

      trie.add("crystal")
      trie.contains?("crystal").should eq(true)
      trie.add("ruby")
      trie.add("rudy")
      trie.add("elixir")
      trie.add("eli")

      trie.contains?("ruby").should eq(true)
      trie.contains?("rudy").should eq(true)
      trie.contains?("crystal").should eq(true)
      trie.contains?("elixir").should eq(true)
      trie.contains?("eli").should eq(true)

      trie.remove("rudy")
      trie.contains?("rudy").should eq(false)
      trie.contains?("bogus").should eq(false)
    end
  end

  describe "#to_a" do
    it "returns the added strings" do
      trie = Data::StringTrie.new

      trie.add("crystal")
      trie.add("ruby")
      trie.add("rudy")
      trie.add("elixir")
      trie.add("eli")
      trie.to_a.should eq(["crystal", "eli", "elixir", "ruby", "rudy"])
    end
  end

  describe "proper nesting" do
    it "makes subtries for nesting" do
      trie = Data::StringTrie.new
      trie.add("crystal")
      trie.add("ruby")
      trie.add("rudy")
      trie.add("elixir")
      trie.add("eli")

      trie.depth.should eq(0)
      trie.buffer[3].should eq("rystal")

      r = trie.buffer[18] as Data::StringTrie
      ru = r.buffer[21] as Data::StringTrie
      ru.depth.should eq(2)
      ru.size.should eq(2)
    end
  end
end
