---
parent: Table Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# table.is_array

Returns whether a table is an array. A table is considered an array if it's empty, or all its keys are sequential numbers starting with `1`.

## Usage

```lua
table.is_array(my_table)
```

### Arguments

| Name       | Type    | Description                   |
| :--------- | :------ | :---------------------------- |
| `my_table` | `table` | Table to test. |

### Returns

| Name    | Type      | Description                                  |
| :------ | :-------- | :------------------------------------------- |
| `result` | `boolean` | True if the table is an array, false otherwise. |

## Examples

```lua
print(table.is_array({})); -- Prints "true"
print(table.is_array({ 1, 2, 3 })); -- Prints "true"
print(table.is_array({ 1, nil, 3 })); -- Prints "false"
print(table.is_array({ a = "hello" })); -- Prints "false"
```
