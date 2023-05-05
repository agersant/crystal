---
parent: crystal.ui
grand_parent: API Reference
nav_order: 1
---

# crystal.ui.font

Returns a previously registered [font](https://love2d.org/wiki/Font).

This function will error if no font has been registered under the requested name.

## Usage

```lua
crystal.ui.font(name)
```

### Arguments

| Name   | Type     | Description |
| :----- | :------- | :---------- |
| `name` | `string` | Font name.  |

### Returns

| Name   | Type                                      | Description  |
| :----- | :---------------------------------------- | :----------- |
| `font` | [love.Font](https://love2d.org/wiki/Font) | Font object. |

## Examples

Registering and retrieving custom fonts:

```lua
crystal.ui.register_font("dialog_xs", love.graphics.newFont("assets/comic_sans.ttf", 12));
crystal.ui.register_font("dialog_sm", love.graphics.newFont("assets/comic_sans.ttf", 14));
crystal.ui.register_font("dialog_md", love.graphics.newFont("assets/comic_sans.ttf", 16));

local font = crystal.ui.font("dialog_md");
```

Retrieving a built-in font:

```lua
local font = crystal.ui.font("crystal_regular_sm");
```
