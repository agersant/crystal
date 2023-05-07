---
parent: crystal.physics
grand_parent: API Reference
nav_order: 1
---

# crystal.physics.define_categories

Sets the list of categories that can describe [colliders](collider) and [sensors](sensor). You should call this function once, from `"main.lua"`.

LOVE supports up to 16 categories. Crystal reserves one of them (named `"level"`), which leaves up to 15 for you to define.

## Usage

```lua
crystal.physics.define_categories(categories)
```

### Arguments

| Name         | Type    | Description                        |
| :----------- | :------ | :--------------------------------- |
| `categories` | `table` | List of category names as strings. |

## Examples

```lua
-- In main.lua
require("crystal");

crystal.physics.define_categories({ "character", "monster", "powerup" });
```
