
Simple data structures implemented in Crystal as a learning experience.

[![Build Status](https://travis-ci.org/rmosolgo/data-structures-crystal.svg)](https://travis-ci.org/rmosolgo/data-structures-crystal)

- [x] LinkedList
- [x] HashTable
- [x] DynamicArray
- Build-up to a hash array mapped trie:
  - [x] String Trie (stores a set of strings)
  - [x] String => Value Trie (stores string => whatever pairs)
  - [x] String Array Mapped Trie (stores a set of strings by hash & a bitmap + array for storage)
- [x] Hash Array Mapped Trie
- [ ] ~~Handle fancy-shmancy negative indexes~~
- [ ] ~~Implement real nice APIs like Crystal stdlib~~


## HAMT performance

```
# [master 74f4a42] implement HAMT
~/projects/crystal-data $ crystal run --release benchmark/hash_array_mapped_trie_benchmark.cr
 Data::HAMT x100        11.22k (±10.35%) 13.49× slower
Stdlib Hash x100       151.37k (± 9.17%)       fastest
 Data::HAMT x10000     145.13  (± 1.22%) 17.62× slower
Stdlib Hash x10000       2.56k (± 1.60%)       fastest
 Data::HAMT x1000000     0.97  (± 7.26%) 15.68× slower
Stdlib Hash x1000000    15.27  (±17.74%)       fastest
```
