---
parent: Table Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# table.serialize

Returns a string representation of a table.

Serializable key types are:

- `number`
- `string`
- `boolean`

Serializable values types are:

- `number`
- `string`
- `boolean`
- `table`

If the table to serialize contains multiple references to the same table, this function will emit an error. For example, the following code will NOT work:

```lua
local animals = { "dog", "cat", "rabbit" };
local cannot_be_serialized = { animals, animals };
table.serialize(cannot_be_serialized); -- Error!
```

## Usage

```lua
table.serialize(my_table)
```

### Arguments

| Name       | Type    | Description         |
| :--------- | :------ | :------------------ |
| `my_table` | `table` | Table to serialize. |

### Returns

| Name         | Type     | Description                         |
| :----------- | :------- | :---------------------------------- |
| `serialized` | `string` | String representation of the table. |

## Examples

```lua
local power_values = { sword = 20, axe = 30, rapier = 14, staff = 8 };
local serialized = table.serialize(power_values);
local deserialized = table.deserialize(serialized);
print(deserialized.rapier); -- Prints "14"
```
