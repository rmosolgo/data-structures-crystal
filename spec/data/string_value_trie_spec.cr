require "../spec_helper"

describe "StringValueTrie" do
  describe "#set / #get / #delete" do
    it "adds and removes elements" do
      trie = Data::StringValueTrie(Int32?).new

      trie.set("crystal", 5)
      trie.set("ruby", 4)
      trie.set("rudy", nil)
      trie.set("elixir", 3)

      trie.size.should eq(4)
      trie.get("ruby").should eq(4)
      trie.get("rudy").should eq(nil)
      trie.get?("whatever").should eq(nil)

      trie.set("ruby", 5)
      trie.size.should eq(4)
      trie.get("ruby").should eq(5)

      trie.delete("ruby")
      trie.delete("elixir")
      trie.size.should eq(2)
    end
  end

  describe "#to_h" do
    it "returns the added strings" do
      trie = Data::StringValueTrie(Symbol).new

      trie.set("crystal", :ok)
      trie.set("ruby", :ok)
      trie.set("rudy", :err)
      trie.set("elixir", :ok)
      trie.set("eli", :err)
      trie.to_h.should eq({
        "crystal" => :ok,
        "ruby" => :ok,
        "elixir" => :ok,
        "eli" => :err,
        "rudy" => :err,
      })
    end
  end

  describe "#each" do
    it "enumerates over key-values" do
      keys = [] of String
      values = [] of Symbol | Int32
      trie = Data::StringValueTrie(Symbol | Int32).new

      trie.set("crystal", 100)
      trie.set("ruby", 200)
      trie.set("rudy", :err)
      trie.set("elixir", 300)
      trie.set("eli", :err)

      trie.each do |key, value|
        keys << key
        values << value
      end
      keys.should eq(["crystal", "eli", "elixir", "ruby", "rudy"])
      values.should eq([100, :err, 300, 200, :err])
    end
  end
end
