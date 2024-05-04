---
parent: Lua Extensions
has_children: true
has_toc: false
---

# Table Extensions

This module contains utility functions for table operations. All functions are registered on the global `table` table and can be accessed as `table.example(my_table)`.

## Functions

| Name                                   | Description                                                                |
| :------------------------------------- | :------------------------------------------------------------------------- |
| [table.append](table_append)           | Adds a list of values at the end of another.                               |
| [table.clear](table_clear)             | Removes all values in a table.                                             |
| [table.contains](table_contains)       | Returns whether a table contains a specific value.                         |
| [table.copy](table_copy)               | Returns a shallow copy of a table.                                         |
| [table.count](table_count)             | Returns the number of `(key, value)` pairs in a table.                     |
| [table.deserialize](table_deserialize) | Creates a table from its string representation.                            |
| [table.deep_copy](table_deep_copy)     | Returns a deep copy of a table.                                            |
| [table.equals](table_equals)           | Returns whether two tables contain the same `(key, value)` pairs.          |
| [table.index_of](table_index_of)       | Returns the index of a value within a list.                                |
| [table.is_empty](table_is_empty)       | Returns whether a table contains any key.                                  |
| [table.map](table_map)                 | Creates a new table by applying a transformation to all values in a table. |
| [table.merge](table_merge)             | Creates a new table containing all `(key, value)` pairs from two tables.   |
| [table.overlay](table_overlay)         | Writes all the `(key, value)` pairs from a table into an existing table.   |
| [table.pop](table_pop)                 | Removes the last element of a list.                                        |
| [table.push](table_push)               | Adds an element at the end of a list.                                      |
| [table.serialize](table_serialize)     | Returns a string representation of a table.                                |
