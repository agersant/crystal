---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:is_focusable

Returns whether this element is [focusable](ui_element_set_focusable).

## Usage

```lua
ui_element:is_focusable()
```

### Returns

| Name        | Type      | Description                                         |
| :---------- | :-------- | :-------------------------------------------------- |
| `focusable` | `boolean` | True if this element is focusable, false otherwise. |

## Examples

```lua
local menu = crystal.Overlay:new();
menu:set_focusable(true);
print(menu:is_focusable()); -- Prints "true"
```
