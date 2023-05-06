---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:set_focusable

Sets whether this element is focusable.

This method should be used to govern whether an element can _ever_ receive focus, and should not be called outside initialization. To temporarily allow or prevent an element from receiving focus, see [set_active](ui_element_set_active).

{: .warning}
This method does not retroactively clear focus when making a focused element unfocusable.

## Usage

```lua
ui_element:set_focusable(focusable)
```

### Returns

| Name        | Type      | Description                                               |
| :---------- | :-------- | :-------------------------------------------------------- |
| `focusable` | `boolean` | True if the element should be focusable, false otherwise. |

## Examples

```lua
local menu = crystal.Overlay:new();
menu:set_focusable(true);
print(menu:is_focusable()); -- Prints "true"
```
