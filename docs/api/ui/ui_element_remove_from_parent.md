---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:remove_from_parent

Removes this element from its parent.

This method emits an error when called on an element with no parent.

## Usage

```lua
ui_element:remove_from_parent()
```

## Examples

```lua
local popup = crystal.Overlay:new();
local title = popup:add_child(crystal.Text:new());
title:remove_from_parent();
assert(title:parent() == nil);
```
