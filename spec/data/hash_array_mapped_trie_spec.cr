require "../spec_helper"

class StupidHashClone
  def initialize(@target)
  end

  def hash
    @target.hash
  end
end

describe "Data::HashArrayMappedTrie" do
  describe "#get / #put" do
    it "adds and removes pairs" do
      hash = Data::HashArrayMappedTrie(String, Symbol?).new
      hash.put("cat", :dog)
      hash.put("fish", :snake)
      hash.put("cricket", nil)

      hash.size.should eq(3)

      hash.get("cat").should eq(:dog)
      hash.get("fish").should eq(:snake)
      hash.get("cricket").should eq(nil)
      hash.get?("cow").should eq(nil)
    end

    it "overrides existing pairs" do
      hash = Data::HashArrayMappedTrie(Symbol, Int32).new
      hash.put(:a, 1)
      hash.get(:a).should eq(1)
      hash.put(:a, 2)
      hash.get(:a).should eq(2)
      hash.size.should eq(1)
    end
  end

  describe "#delete" do
    it "removes pairs" do
      hash = Data::HashArrayMappedTrie(Int32, Int32).new
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

  describe "hash conflicts" do
    it "still works" do
      hash = Data::HashArrayMappedTrie(Float64 | StupidHashClone, Int32).new
      pi = 3.14
      pi_clone_1 = StupidHashClone.new(pi)
      pi_clone_2 = StupidHashClone.new(pi)
      hash.put(pi, 0)
      hash.put(pi_clone_1, 1)
      hash.put(pi_clone_2, 2)
      hash.size.should eq(3)
      hash.get(pi).should eq(0)
      hash.get(pi_clone_1).should eq(1)
      hash.get(pi_clone_2).should eq(2)

      hash.delete(pi)
      hash.size.should eq(2)
      hash.get?(pi).should eq(nil)
      hash.get(pi_clone_1).should eq(1)
      hash.get(pi_clone_2).should eq(2)

      hash.delete(pi_clone_2)
      hash.size.should eq(1)
      hash.get?(pi).should eq(nil)
      hash.get(pi_clone_1).should eq(1)
      hash.get?(pi_clone_2).should eq(nil)

      hash.delete(pi_clone_1)
      hash.size.should eq(0)
      hash.get?(pi).should eq(nil)
      hash.get?(pi_clone_1).should eq(nil)
      hash.get?(pi_clone_2).should eq(nil)
    end

    it "works with numbers" do
      hash = Data::HashArrayMappedTrie(Int32, Int32).new
      10_000.times do |i|
        hash[i] = i
        if hash.bitmap < 0
          puts [i, hash.bitmap]
          raise("Stahp")
        end
      end
      # some kind of weird conflict
      puts 248.hash.to_i32.to_s(2)
      hash.get(248).should eq(248)
    end
  end

  describe "#each" do
    it "enumerates in unknown order" do
      # hash = Data::HashArrayMappedTrie(Int32, Symbol).new
      # hash.put(1, :one)
      # hash.put(2, :two)
      # hash.put(3, :three)
      # sum_of_keys = hash.map { |k, v| k }.inject { |m, i| m + i }
      # values = hash.map { |k, v| v }
      # sum_of_keys.should eq(6)
      # values.should eq([:one, :two, :three])
    end
  end
end
