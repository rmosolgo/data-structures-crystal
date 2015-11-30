require "../spec_helper"

describe "StringArrayMappedTrie" do
  describe "#add / #remove" do
    it "adds and removes elements" do
      trie = Data::StringArrayMappedTrie.new

      trie.add("crystal")
      trie.add("ruby")
      trie.add("rudy")
      trie.add("elixir")

      trie.bitmap.should eq(1)
      trie.size.should eq(4)

      trie.remove("ruby")
      trie.remove("elixir")
      trie.size.should eq(2)
    end
  end

  describe "#contains?" do
    it "tells membership" do
      trie = Data::StringArrayMappedTrie.new
      trie.contains?("crystal").should eq(false)

      trie.add("crystal")
      trie.contains?("crystal").should eq(true)
      trie.add("ruby")
      trie.add("qway")
      trie.add("rudy")
      trie.add("elixir")
      trie.add("eli")

      trie.contains?("crystal").should eq(true)
      trie.contains?("ruby").should eq(true)
      trie.contains?("qway").should eq(true)
      trie.contains?("rvay").should eq(false)

      trie.contains?("rudy").should eq(true)
      trie.contains?("elixir").should eq(true)
      trie.contains?("eli").should eq(true)

      trie.remove("rudy")
      trie.contains?("rudy").should eq(false)
      trie.contains?("bogus").should eq(false)
    end
  end

  describe "#to_a" do
    it "returns the added strings" do
      trie = Data::StringArrayMappedTrie.new

      trie.add("crystal")
      trie.add("ruby")
      trie.add("rudy")
      trie.add("elixir")
      trie.add("eli")
      trie.to_a.should eq(["crystal", "eli", "elixir", "ruby", "rudy"])
    end
  end
end
