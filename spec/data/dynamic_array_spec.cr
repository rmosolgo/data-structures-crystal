require "../spec_helper"

describe "Data::DynamicArray" do
  describe "#push / #pop" do
    it "pushes and pops from the end" do
      list = Data::DynamicArray(Symbol).new(:a, :b, :c)
      list.size.should eq(3)

      list.push(:d)
      list.size.should eq(4)
      list.last.should eq(:d)
      list.push(:e)
      list.pop.should eq(:e)
      list.pop.should eq(:d)
      list.pop.should eq(:c)

      list.last.should eq(:b)
      list.first.should eq(:a)
      list.size.should eq(2)

      list.pop
      list.pop

      list.size.should eq(0)
      list.first.should eq(nil)
      list.last.should eq(nil)

      list.pop?.should eq(nil)
      list.size.should eq(0)

      list.push(:ABC)
      list.size.should eq(1)
      list.first.should eq(:ABC)
      list.last.should eq(:ABC)
    end
  end
  describe "#unshift / #shift" do
    it "shifts and unshifts from the start" do
      list = Data::DynamicArray(Int32).new(12,34,56)
      list.first.should eq(12)
      list.size.should eq(3)

      list.unshift(78)
      list.unshift(90)
      list.first.should eq(90)
      list.size.should eq(5)

      list.shift.should eq(90)
      list.shift.should eq(78)
      list.shift.should eq(12)

      list.first.should eq(34)
      list.size.should eq(2)

      list.shift
      list.shift
      list.shift?.should eq(nil)
      list.size.should eq(0)
      list.first.should eq(nil)
      list.last.should eq(nil)

      list.unshift(59)
      list.size.should eq(1)
      list.first.should eq(59)
      list.last.should eq(59)
    end
  end
  describe "#at / #set / #insert / #delete" do
    it "works with specific indexes" do
      list = Data::DynamicArray(Symbol | Int32 | String | Hash(Symbol, Int32)).new(:a, 1, "a", {a: 1})
      list.at(0).should eq(:a)
      list.at(3).should eq({a: 1})

      list.set(0, :A)
      list.at(0).should eq(:A)
      list.insert(0, 7)
      list.at(0).should eq(7)
      list.at(1).should eq(:A)
      list.at(2).should eq(1)
      list.at(4).should eq({a: 1})
      list.size.should eq(5)

      list.delete(0).should eq(7)
      list.delete(3).should eq({a: 1})
      list.first.should eq(:A)
      list.last.should eq("a")
      list.size.should eq(3)

      list.push(:A)
      list.insert(2, :B)
      list.set(2, :C)
      list.at(2).should eq(:C)
      list.at(3).should eq("a")
      list.size.should eq(5)
    end
  end

  describe "#each / enumeration" do
    it "enumerates over values" do
      l = Data::DynamicArray(Int32).new(1,2,3,4,5)
      result = l.map { |i| i * 2 }.inject { |m, i| i + m }
      result.should eq(30)
      l.to_a.should eq([1,2,3,4,5])
      l.minmax.should eq({1, 5})
    end
  end

  describe "#concat" do
    it "joins into a new array" do
      list_1 = Data::DynamicArray(Char).new('1', '2')
      list_2 = Data::DynamicArray(Char).new('3', '4', '5', '6')
      list_3 = list_1.concat(list_2)
      list_1.size.should eq(2)
      list_2.size.should eq(4)
      list_3.size.should eq(6)
      list_3.to_a.should eq(['1', '2', '3', '4', '5','6'])
    end
  end

  describe "resizing" do
    it "resizes when it grows" do
      list = Data::DynamicArray(Int32).new
      20.times { |i| list.push(i) }
      list.size.should eq(20)
      list.capacity.should eq(32)

      100.times { |i| list.unshift(-i) }
      list.size.should eq(120)
      list.capacity.should eq(128)
    end
  end
end
