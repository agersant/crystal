---
parent: crystal.assets
grand_parent: API Reference
nav_exclude: true
---

# Spritesheet:animation

Retrieves an animation by name.

## Usage

```lua
spritesheet:animation(name)
```

### Arguments

| Name   | Type     | Description                        |
| :----- | :------- | :--------------------------------- |
| `name` | `string` | Name of the animation to retrieve. |

### Returns

| Name        | Type                   | Description      |
| :---------- | :--------------------- | :--------------- |
| `animation` | [Animation](animation) | Width in pixels. |

## Examples

```lua
local spritesheet = crystal.assets.get("assets/sprites/hero.lua");
local walk = spritesheet:animation("walk");
```
