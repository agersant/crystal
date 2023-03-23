---
parent: Table Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# table.is_empty

Returns whether a table contains any key.

## Usage

```lua
table.is_empty(my_table)
```

### Arguments

| Name       | Type    | Description                   |
| :--------- | :------ | :---------------------------- |
| `my_table` | `table` | Table to look for a value in. |

### Returns

| Name    | Type      | Description                                  |
| :------ | :-------- | :------------------------------------------- |
| `empty` | `boolean` | True if the table is empty, false otherwise. |

## Examples

```lua
print(table.is_empty({})); -- Prints "true"
print(table.is_empty({ 1, 2, 3 })); -- Prints "false"
```
