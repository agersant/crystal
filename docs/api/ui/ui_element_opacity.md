---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:opacity

Returns this element's opacity.

## Usage

```lua
ui_element:opacity()
```

### Returns

| Name      | Type     | Description                                                                                |
| :-------- | :------- | :----------------------------------------------------------------------------------------- |
| `opacity` | `number` | Element opacity between `0` and `1`. A value of `0` indicates a fully transparent element. |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("sword.png"));
image:set_opacity(0.5);
print(image:opacity()); -- Prints "0.5"
```
