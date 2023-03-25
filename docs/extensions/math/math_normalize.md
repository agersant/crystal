---
parent: Math Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# math.normalize

Scales a 2D vector to length 1.

This function will error when applied to a zero-length vector.

## Usage

```lua
math.normalize(x, y)
```

### Arguments

| Name | Type     | Description                 |
| :--- | :------- | :-------------------------- |
| `x`  | `number` | X coordinate of the vector. |
| `y`  | `number` | Y coordinate of the vector. |

### Returns

| Name | Type     | Description                            |
| :--- | :------- | :------------------------------------- |
| `x`  | `number` | X coordinate of the normalized vector. |
| `y`  | `number` | X coordinate of the normalized vector. |

## Examples

```lua
local x, y = math.normalize(10, 20);
print(math.length(x, y)); -- Prints "1"
```
