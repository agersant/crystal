---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Animation:is_looping

Returns whether this animation loops when it finishes.

## Usage

```lua
animation:is_looping()
```

### Returns

| Name    | Type      | Description                                   |
| :------ | :-------- | :-------------------------------------------- |
| `loops` | `boolean` | True for looping animations, false otherwise. |

## Examples

```lua
local hero = crystal.assets.get("assets/sprites/hero.lua");
local walk = spritesheet:animation("walk");
print(walk:is_looping());
```
