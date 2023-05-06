---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:set_pivot_y

Sets the vertical position of this element's pivot. A value of `0` indicates the top edge of the element, a value of `1` indicates the bottom edge of the element. Other values are interpolated between (or outside) these two.

## Usage

```lua
ui_element:set_pivot_y(pivot)
```

### Arguments

| Name    | Type     | Description                                |
| :------ | :------- | :----------------------------------------- |
| `pivot` | `number` | Pivot position, often between `0` and `1`. |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("sword.png"));
image:set_pivot_x(1); -- Pivot position is now on the bottom edge of the image
```
