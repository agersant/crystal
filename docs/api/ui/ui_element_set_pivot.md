---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:set_pivot

Sets this element's pivot, around which it scales and rotates. Values are relative to the element's size. A pivot of `(0, 0)` is in the top-left corner of the element, while `(1, 1)` is in the bottom right. The default value for new elements is `(0.5, 0.5)`, in their center.

## Usage

```lua
ui_element:set_pivot(pivot_x, pivot_y)
```

### Arguments

| Name      | Type     | Description                                           |
| :-------- | :------- | :---------------------------------------------------- |
| `pivot_x` | `number` | Horizontal pivot position, often between `0` and `1`. |
| `pivot_y` | `number` | Vertical pivot position, often between `0` and `1`.   |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("sword.png"));
image:set_pivot(1, 0); -- Image now scales and rotates around its top-right corner
print(image:pivot()); -- Prints "1, 0"
```
