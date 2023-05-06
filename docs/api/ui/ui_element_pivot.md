---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:pivot

Returns this element's pivot, around which it scales and rotates.

The default pivot position is `(0.5, 0.5)`, which correponds to the center of the element.

## Usage

```lua
ui_element:pivot()
```

### Returns

| Name      | Type     | Description                                                        |
| :-------- | :------- | :----------------------------------------------------------------- |
| `pivot_x` | `number` | Horizontal position of the pivot point, often between `0` and `1`. |
| `pivot_y` | `number` | Vertical position of the pivot point, often between `0` and `1`.   |

## Examples

```lua
local image = crystal.Image:new(crystal.assets.get("sword.png"));
image:set_pivot(1, 0); -- Image now scales and rotates around its top-right corner
print(image:pivot()); -- Prints "1, 0"
```
