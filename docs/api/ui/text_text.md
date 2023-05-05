---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Text:text

Returns the text to display.

## Usage

```lua
text:text()
```

### Returns

| Name    | Type     | Description      |
| :------ | :------- | :--------------- |
| `value` | `string` | Text to display. |

## Examples

```lua
local text = crystal.Text:new("Bronze Sword");
print(text:text()); -- Prints "Bronze Sword"
```
