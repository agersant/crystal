---
parent: API Reference
has_children: false
has_toc: false
---

# crystal.table

This module contains utility functions for table operations. All functions are registered on the global `table` table and be accessed as `table.example(my_table)`.

## Functions

| Name                             | Description                                                                |
| :------------------------------- | :------------------------------------------------------------------------- |
| [contains](table_contains)       | Returns whether a table contains a specific value.                         |
| [copy](table_copy)               | Returns a shallow copy of a table.                                         |
| [count](table_count)             | Returns the number of `(key, value)` pairs in a table.                     |
| [deserialize](table_deserialize) | Creates a table from its string representation.                            |
| [equals](table_equals)           | Returns whether two tables contain the same `(key, value)` pairs.          |
| [is_empty](table_is_empty)       | Returns whether a table contains any key.                                  |
| [map](table_map)                 | Creates a new table by applying a transformation to all values in a table. |
| [merge](table_merge)             | Creates a new table containing all `(key, value)` pairs from two tables.   |
| [pop](table_pop)                 | Removes the last element of a list.                                        |
| [push](table_push)               | Adds an element at the end of a list.                                      |
| [serialize](table_serialize)     | Returns a string representation of a table.                                |
