---
parent: crystal.table
grand_parent: API Reference
nav_order: 1
---

# table.deserialize

Creates a table from its string representation.

## Usage

```lua
table.deserialize(serialized)
```

### Arguments

| Name         | Type     | Description                       |
| :----------- | :------- | :-------------------------------- |
| `serialized` | `string` | String representation of a table. |

### Returns

| Name           | Type    | Description                                       |
| :------------- | :------ | :------------------------------------------------ |
| `deserialized` | `table` | Table constructed from the string representation. |

## Examples

```lua
local power_values = { sword = 20, axe = 30, rapier = 14, staff = 8 };
local serialized = table.serialize(power_values);
local deserialized = table.deserialize(serialized);
print(deserialized.rapier); -- Prints "14"
```
