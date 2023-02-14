---
parent: crystal.const
grand_parent: API Reference
nav_order: 1
---

# crystal.const.get

Reads the value of a constant.

## Usage

```lua
crystal.const.get(name)
```

### Arguments

| Name   | Type     | Description           |
| :----- | :------- | :-------------------- |
| `name` | `string` | Name of the constant. |

## Examples

```lua
crystal.const.define("enemy_hp", 100, { min = 1, max = 1000 });
print(crystal.const.get("enemy_hp")); -- prints 100
```
