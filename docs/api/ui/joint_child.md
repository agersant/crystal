---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Joint:child

Returns the child this joint is affecting.

## Usage

```lua
joint:child()
```

### Returns

| Name      | Type                                    | Description       |
| :-------- | :-------------------------------------- | :---------------- |
| `element` | [UIElement](/crystal/api/ui/ui_element) | Child UI element. |

## Examples

```lua
local overlay = crystal.Overlay:new();
local image = overlay:add_child(crystal.Image:new());
assert(image:joint():child() == image);
assert(image:joint():parent() == overlay);
```
