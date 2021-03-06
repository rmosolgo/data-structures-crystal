require "../spec_helper"

describe "Data::HashTable" do
  describe "#get / #put" do
    it "adds and removes pairs" do
      hash = Data::HashTable(String, Symbol?).new
      hash.put("cat", :dog)
      hash.put("fish", :snake)
      hash.put("cricket", nil)
      hash.get("cat").should eq(:dog)
      hash.get("fish").should eq(:snake)
      hash.get("cricket").should eq(nil)
      hash.get?("cow").should eq(nil)
      hash.size.should eq(3)
    end

    it "overrides existing pairs" do
      hash = Data::HashTable(Symbol, Int32).new
      hash.put(:a, 1)
      hash.get(:a).should eq(1)
      hash.put(:a, 2)
      hash.get(:a).should eq(2)
      hash.size.should eq(1)
    end
  end

  describe "#delete" do
    it "removes pairs" do
      hash = Data::HashTable(Int32, Int32).new
      hash.put(1, 100)
      hash.put(2, 200)
      hash.delete(1).should eq(100)
      hash.delete(1).should eq(nil)
      hash.get?(2).should eq(200)
      hash.get?(1).should eq(nil)
      hash.size.should eq(1)
      hash.delete(2).should eq(200)
      hash.size.should eq(0)
    end
  end

  describe "#slots_count" do
    it "rehashes" do
      hash = Data::HashTable(Int32, Int32).new
      hash.slots_count.should eq(11)
      100.times { |i| hash.put(i, i * 2) }
      hash.size.should eq(100)
      hash.slots_count.should eq(22)
      1000.times { |i| hash.put(i + 1000, i * 3) }
      hash.size.should eq(1100)
      hash.slots_count.should eq(352)
    end
  end

  describe "#each" do
    it "enumerates in unknown order" do
      hash = Data::HashTable(Int32, Symbol).new
      hash.put(1, :one)
      hash.put(2, :two)
      hash.put(3, :three)
      sum_of_keys = hash.map { |k, v| k }.inject { |m, i| m + i }
      values = hash.map { |k, v| v }
      sum_of_keys.should eq(6)
      values.should eq([:one, :two, :three])
    end
  end
end
