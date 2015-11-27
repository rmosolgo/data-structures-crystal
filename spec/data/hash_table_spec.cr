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
      hash.delete(1)
      hash.get?(2).should eq(200)
      hash.get?(1).should eq(nil)
      hash.size.should eq(1)
      hash.delete(2)
      hash.size.should eq(0)
    end
  end
end
