---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Text:text_alignment

Returns how text is aligned within this element.

## Usage

```lua
text:text_alignment()
```

### Returns

| Name        | Type                                                | Description                                 |
| :---------- | :-------------------------------------------------- | :------------------------------------------ |
| `alignment` | [love.AlignMode](https://love2d.org/wiki/AlignMode) | Text alignment used when drawing this text. |

## Examples

```lua
local text = crystal.Text:new("Hello World");
text:set_text_alignment("center");
print(text:text_alignment()); -- Prints "center"
```
