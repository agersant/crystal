---
parent: crystal.ui
grand_parent: API Reference
nav_order: 2
---

# crystal.Text

A [UI element](ui_element) which draws text.

## Constructor

```lua
crystal.Text:new(initial_text)
```

If ommitted, the `initial_text` to display defaults to `""`. The default alignment is `"left"`, and the default font is `"crystal_bold_md"` ([Source Code Pro Bold](https://github.com/adobe-fonts/source-code-pro) at size `16`).

## Methods

| Name                                          | Description                                      |
| :-------------------------------------------- | :----------------------------------------------- |
| [font](text_font)                             | Returns the name of the font used to draw text.  |
| [set_font](text_set_font)                     | Sets the font used to draw text.                 |
| [set_text_alignment](text_set_text_alignment) | Sets how text is aligned within this element.    |
| [set_text](text_set_text)                     | Sets the text to display.                        |
| [text_alignment](text_text_alignment)         | Returns how text is aligned within this element. |
| [text](text_text)                             | Returns the text to display.                     |

## Examples

```lua
local text = crystal.Text:new("Hello World");
text:set_alignment("center");
```
