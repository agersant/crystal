---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Text:set_font

Sets the font used to draw text. The `font_name` must be a built-in font or a font you have previously [registered](register_font).

The list of built-in fonts is:

| Name                   | Typeface                | Size |
| :--------------------- | :---------------------- | :--- |
| `"crystal_regular_xs"` | Source Code Pro Regular | 12pt |
| `"crystal_regular_sm"` | Source Code Pro Regular | 14pt |
| `"crystal_regular_md"` | Source Code Pro Regular | 16pt |
| `"crystal_regular_lg"` | Source Code Pro Regular | 18pt |
| `"crystal_regular_xl"` | Source Code Pro Regular | 20pt |
| `"crystal_bold_xs"`    | Source Code Pro Bold    | 12pt |
| `"crystal_bold_sm"`    | Source Code Pro Bold    | 14pt |
| `"crystal_bold_md"`    | Source Code Pro Bold    | 16pt |
| `"crystal_bold_lg"`    | Source Code Pro Bold    | 18pt |
| `"crystal_bold_xl"`    | Source Code Pro Bold    | 20pt |

## Usage

```lua
text:set_font(font_name)
```

### Arguments

| Name        | Type     | Description                         |
| :---------- | :------- | :---------------------------------- |
| `font_name` | `string` | Name of the font used to draw text. |

## Examples

```lua
local text = crystal.Text:new("Hello World");
text:set_font("crystal_regular_sm");
print(text:font()); -- Prints "crystal_regular_sm"
```
