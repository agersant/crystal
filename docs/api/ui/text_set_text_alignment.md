---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Text:set_text_alignment

Sets how text is aligned within this element.

## Usage

```lua
text:set_text_alignment(alignment)
```

### Arguments

| Name        | Type                                                | Description                                   |
| :---------- | :-------------------------------------------------- | :-------------------------------------------- |
| `alignment` | [love.AlignMode](https://love2d.org/wiki/AlignMode) | Text alignment to use when drawing this text. |

## Examples

```lua
local text = crystal.Text:new("Hello World");
text:set_text_alignment("center");
print(text:text_alignment()); -- Prints "center"
```
