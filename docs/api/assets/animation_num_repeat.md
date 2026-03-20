---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Animation:num_repeat

Returns how many times this animation plays before stopping.

## Usage

```lua
animation:num_repeat()
```

### Returns

| Name      | Type      | Description                                                           |
| :-------- | :-------- | :-------------------------------------------------------------------- |
| `repeats` | `number`  | Number of times this animation plays, or `nil` if it repeats forever. |

## Examples

```lua
local hero = crystal.assets.get("assets/sprites/hero.json");
local walk = spritesheet:animation("walk");
print(walk:num_repeat());
```
