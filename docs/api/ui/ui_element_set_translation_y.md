---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:set_translation_y

Sets this element's vertical translation.

Translation does not affect an element's layout, it is only a visual effect.

## Usage

```lua
ui_element:set_translation_y(offset)
```

### Arguments

| Name     | Type     | Description    |
| :------- | :------- | :------------- |
| `offset` | `number` | Offset amount. |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("sword.png"));
image:set_translation_y(10);
```
