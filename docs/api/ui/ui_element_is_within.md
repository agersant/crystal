---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:is_within

Returns whether this element is a descendant of another one.

## Usage

```lua
ui_element:is_within(other)
```

### Arguments

| Name    | Type                    | Description                                              |
| :------ | :---------------------- | :------------------------------------------------------- |
| `other` | [UIElement](ui_element) | Element which may or may not be an ancestor of this one. |

### Returns

| Name     | Type      | Description                                                      |
| :------- | :-------- | :--------------------------------------------------------------- |
| `within` | `boolean` | True if `other` is an ancestor of this element, false otherwise. |

## Examples

```lua
local pause_menu = crystal.Overlay:new();
local hud = crystal.Overlay:new();
local health_bar = hud:add_child(crystal.Overlay:new());
local health_bar_background = health_bar:add_child(crystal.Image:new());

print(health_bar_background:is_within(hud)); -- Prints "true"
print(health_bar_background:is_within(menu)); -- Prints "false"
```
