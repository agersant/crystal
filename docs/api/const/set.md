---
parent: crystal.const
grand_parent: API Reference
nav_order: 1
---

# crystal.const.set

Sets the value of a constant.

{: .warning }
This function does nothing in [fused builds](https://love2d.org/wiki/love.filesystem.isFused).

## Usage

```lua
crystal.const.set(name, value)
```

### Arguments

| Name    | Type     | Description                                                                                |
| :------ | :------- | :----------------------------------------------------------------------------------------- |
| `name`  | `string` | Name of the constant.                                                                      |
| `value` | `any`    | New value for the constant. The type of this argument must match the type of the constant. |

## Examples

```lua
crystal.const.define("EnemyHP", 100, { min = 1, max = 1000 });
crystal.const.set("EnemyHP", 80);
```
