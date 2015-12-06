require "benchmark"
require "../src/data"

def test_collection(times, collection)
  times.times do |i|
    collection[i] = 1
  end
  times.times do |i|
    collection[i]
  end
  times.times do |i|
    collection.delete(i)
  end
end


[100, 10_000, 1_000_000].each do |times|
  Benchmark.ips do |x|
    x.report("Data::HAMT x#{times.to_s.ljust(9)}") { test_collection(times, Data::HashArrayMappedTrie(Int32, Int32).new) }
    x.report("Stdlib Hash x#{times.to_s.ljust(9)}") { test_collection(times, Hash(Int32, Int32).new) }
  end
end
