---
parent: crystal.ui
grand_parent: API Reference
nav_order: 1
---

# crystal.ui.register_font

Registers a [font](https://love2d.org/wiki/Font).

When calling this function with a name that was used previously, the old font will be overridden. Since LOVE fonts only exist at a given size, you may want to re-register fonts with adjusted sizes when the game window is resized.

{: .warning}
Font names starting with `crystal` are reserved for internal use. Attempting to register such a font will cause this function to error.

## Usage

```lua
crystal.ui.register_font(name, font)
```

### Arguments

| Name   | Type                                      | Description  |
| :----- | :---------------------------------------- | :----------- |
| `name` | `string`                                  | Font name.   |
| `font` | [love.Font](https://love2d.org/wiki/Font) | Font object. |

## Examples

Registering and retrieving custom fonts:

```lua
crystal.ui.register_font("dialog_xs", love.graphics.newFont("assets/comic_sans.ttf", 12));
crystal.ui.register_font("dialog_sm", love.graphics.newFont("assets/comic_sans.ttf", 14));
crystal.ui.register_font("dialog_md", love.graphics.newFont("assets/comic_sans.ttf", 16));

local font = crystal.ui.font("dialog_md");
```
