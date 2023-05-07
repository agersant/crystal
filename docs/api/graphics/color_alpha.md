---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# Color:alpha

Creates a new color with the same RGB components and a specific alpha.

## Usage

```lua
color:alpha(opacity)
```

### Arguments

| Name      | Type     | Description                                    |
| :-------- | :------- | :--------------------------------------------- |
| `opacity` | `number` | Opacity of the new color, between `0` and `1`. |

### Returns

| Name    | Type           | Description |
| :------ | :------------- | :---------- |
| `color` | [Color](color) | New color.  |

## Examples

```lua
local pink  = crystal.Color:new(0xFFC0CB);
love.graphics.setColor(pink:alpha(0.2));
```
