---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Switcher:active_child

Returns which of its children this switcher is drawing. If a transition is in progress, this returns the child being transitioned to.

An empty `Switcher` has no active child. When you first add a child to a `Switcher`, it immediately becomes the active child.

This function is unrelated to [UIElement:set_active](ui_element_set_active).

## Usage

```lua
switcher:active_child()
```

### Returns

| Name    | Type                             | Description   |
| :------ | :------------------------------- | :------------ |
| `child` | [UIElement](ui_element) \| `nil` | Active child. |

## Examples

```lua
local manual = crystal.Switcher:new();
local page_1 = manual:add_child(crystal.Image:new(crystal.assets.get("page_1.png")));
local page_2 = manual:add_child(crystal.Image:new(crystal.assets.get("page_2.png")));
local page_3 = manual:add_child(crystal.Image:new(crystal.assets.get("page_3.png")));

assert(manual:active_child() == page_1);
manual:switch_to(page_2);
assert(manual:active_child() == page_2);
```
