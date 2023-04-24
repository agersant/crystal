---
parent: Table Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# table.index_of

Returns the index of a value within a list.

## Usage

```lua
table.index_of(my_table, my_value)
```

### Arguments

| Name       | Type    | Description                   |
| :--------- | :------ | :---------------------------- |
| `my_table` | `table` | Table to look for a value in. |
| `my_value` | `any`   | Value to look for.            |

### Returns

| Name    | Type              | Description                                                                           |
| :------ | :---------------- | :------------------------------------------------------------------------------------ |
| `index` | `number` \| `nil` | First index with a value matching `my_value`, `nil` if `my_value` is not in the list. |

## Examples

```lua
print(table.index_of({ "a", "b", "c" }, "b")); -- Prints "2"
```
