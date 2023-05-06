---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:is_active

Returns whether this element is [active](ui_element_set_active). All elements are active by default.

## Usage

```lua
ui_element:is_active()
```

### Returns

| Name     | Type      | Description                                      |
| :------- | :-------- | :----------------------------------------------- |
| `active` | `boolean` | True if this element is active, false otherwise. |

## Examples

```lua
local menu = crystal.Overlay:new();
menu:set_active(false);
print(menu:is_active()); -- Prints "false"
```
