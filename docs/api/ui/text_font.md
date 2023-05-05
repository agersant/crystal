---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Text:font

Returns the name of the font used to draw text.

The actual font object can be retrieved via [crystal.ui.font()](font) if needed.

## Usage

```lua
text:font()
```

### Returns

| Name        | Type     | Description                         |
| :---------- | :------- | :---------------------------------- |
| `font_name` | `string` | Name of the font used to draw text. |

## Examples

```lua
local text = crystal.Text:new("Hello World");
text:set_font("crystal_regular_sm");
print(text:font()); -- Prints "crystal_regular_sm"
```
