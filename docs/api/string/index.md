---
parent: API Reference
has_children: false
has_toc: false
---

# crystal.string

This module contains utility functions for string manipulation. All functions are registered on the global `string` table and be accessed as `string.example(my_string)` or `my_string:example()`.

For all functions operating on filesystem paths, `"\"` and `"/"` are treated as equivalent path separators. All filesystem paths may be absolute or relative.

## Functions

| Name                                                       | Description                                                             |
| :--------------------------------------------------------- | :---------------------------------------------------------------------- |
| [string.file_extension](string_file_extension)             | Returns the file extension from a filesystem path.                      |
| [string.merge_paths](string_merge_paths)                   | Merges two filesystem paths.                                            |
| [string.parent_directory](string_parent_directory)         | Returns a copy of a filesystem path without its final component.        |
| [string.split](string_split)                               | Splits a string into a table, matching on specific delimiters.          |
| [string.strip_file_extension](string_strip_file_extension) | Returns a copy of a filesystem path without its file extension.         |
| [string.strip_whitespace](string_strip_whitespace)         | Returns a copy of a string with all whitespace removed.                 |
| [string.trim](string_trim)                                 | Returns a copy of a string with starting and ending whitespace removed. |
