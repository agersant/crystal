---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Text:set_text

Sets the text to display.

## Usage

```lua
text:set_text(value)
```

### Arguments

| Name    | Type                 | Description      |
| :------ | :------------------- | :--------------- |
| `value` | `string` \| `number` | Text to display. |

## Examples

```lua
local text = crystal.Text:new();
text:set_text("Welcome aboard!");
```

```lua
local text = crystal.Text:new();
text:set_text(56);
```
