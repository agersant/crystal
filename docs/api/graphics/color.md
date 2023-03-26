---
parent: crystal.graphics
grand_parent: API Reference
---

# crystal.Color

A color, with RGBA components.

{: .note}
Color components are stored in the array part of these objects. This makes them compatible with LOVE functions that expect colors as `{r, g, b}` or `{r, g, b, a}` tables.

## Constructor

```lua
crystal.Color:new(hex_rgb, alpha)
```

- The `hex_rgb` parameter is a `number` (not a `string`!) listing the RGB components of the color (8 bits per channel). If `nil` or omitted, it defaults to `0x000000` (black).
- The alpha parameter is a number between 0 and 1 indicating the color opacity. If `nil` or omitted, it defaults to 1 (fully opaque).

```lua
local black_opaque  = crystal.Color:new();
local pink_opaque  = crystal.Color:new(0xFFC0CB, 1);
local turquoise_transparent  = crystal.Color:new(0x30D5C8, 0.5);
```

## Methods

| Name                 | Description                                                            |
| :------------------- | :--------------------------------------------------------------------- |
| [alpha](color_alpha) | Creates a new color with the same RGB components and a specific alpha. |

## Examples

```lua
local orange = crystal.Color:new(0xFFA500);
love.graphics.setColor(orange);
love.graphics.rectangle("fill", 20, 50, 60, 120);
```
