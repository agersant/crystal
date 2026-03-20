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

| Name        | Type                   | Description                                 |
| :---------- | :--------------------- | :------------------------------------------ |
| `animation` | [Animation](animation) | Animation with the specified name (or nil). |

## Examples

```lua
local spritesheet = crystal.assets.get("assets/sprites/hero.json");
local walk = spritesheet:animation("walk");
```
